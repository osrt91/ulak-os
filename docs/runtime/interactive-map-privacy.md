# Interactive Map Privacy Pattern

## Why this exists

Products showing events, locations, or geographic data on interactive maps (Leaflet, Mapbox, Google Maps) create a privacy + UX surface that's easy to mishandle. A map that requests browser geolocation on first load without consent is a dark pattern. A map that renders 10k markers in a cluster at world-zoom is a performance and privacy footgun (exposes every point at once). A map that embeds a third-party provider API that the privacy policy didn't declare is a compliance miss.

Yeyclub.com (and any community / event / ecommerce product with location data) needs a discipline layer.

## When to apply

Apply when the product exposes:
- Event location discovery (community platforms, meetups, conferences)
- User location on profile / activity (social, fitness)
- Business locations (storefront finder, restaurant map)
- Shipping / delivery maps

## Discipline

### Consent before geolocation

- NEVER call `navigator.geolocation.getCurrentPosition()` on page load without user action
- Default map view: project's primary service area (e.g., country bounding box), not "request user location"
- Explicit button / toggle: "Show events near me" → fires consent prompt
- Consent captured: record in session / DB so you don't re-prompt on every visit

### Marker clustering for scale

- Any map with >20 markers MUST cluster — raw marker rendering beyond 20 pts degrades UX on mobile
- Clustering library: `leaflet.markercluster`, `supercluster`, or Mapbox native clustering
- Cluster bubbles show count; click to zoom or expand
- Privacy bonus: clustering hides individual point precision at low zoom levels

### Zoom + panning defaults

- Initial zoom: city-level if user is in service area; country-level otherwise
- Minimum zoom: prevent world-zoom showing every point (perf + privacy)
- Maximum zoom: match tile provider's capability; beyond that → blank, not confusing
- Pan bounds: restrict to service area for community/regional products

### Tile provider governance

- Every tile provider (Leaflet default = OSM; Mapbox; Google; custom) MUST be declared in the privacy policy
- Tile requests leak: user IP + approximate location + timestamp to the provider
- Server-side tile proxy: option when you don't want client to contact the provider directly

### Location data in database

- Store coordinates as `POINT` / PostGIS `geography` — NOT `text`
- Sensitivity: event organizer's home address should NEVER be the stored event location if it's a private home; use a public landmark alias
- Retention: delete coordinates when event passes + N days (event-scoped); user profile coordinates follow user retention

### Accessibility

- Every marker has accessible description (`aria-label` with event name, date, location text)
- Map is keyboard-navigable: tab through markers, Enter to open popup
- Non-map fallback: list view of the same data for screen-reader-only users

## Worked example — community-platform.com

```typescript
// components/EventMap.tsx (sketch)
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import MarkerClusterGroup from 'react-leaflet-markercluster'

export function EventMap({ events, userLocation }: Props) {
  // Default to Istanbul bounds if no user location
  const defaultCenter: LatLng = userLocation ?? [41.0082, 28.9784]
  const defaultZoom = userLocation ? 13 : 10

  return (
    <MapContainer
      center={defaultCenter}
      zoom={defaultZoom}
      minZoom={5}      // prevent world-zoom
      maxZoom={18}
      maxBounds={[[35, 25], [43, 45]]}  // Turkey bounding box
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; OpenStreetMap contributors'
      />
      {events.length > 20 ? (
        <MarkerClusterGroup>
          {events.map(e => <EventMarker key={e.id} event={e} />)}
        </MarkerClusterGroup>
      ) : (
        events.map(e => <EventMarker key={e.id} event={e} />)
      )}
    </MapContainer>
  )
}

function EventMarker({ event }: { event: Event }) {
  return (
    <Marker position={event.location} aria-label={`Event: ${event.name} on ${event.date}`}>
      <Popup>
        <strong>{event.name}</strong>
        <div>{event.date}</div>
        <div>{event.address}</div>
      </Popup>
    </Marker>
  )
}
```

```typescript
// hooks/useLocationPermission.ts
export function useLocationPermission() {
  const [location, setLocation] = useState<LatLng | null>(null)
  const [status, setStatus] = useState<'idle' | 'granted' | 'denied'>('idle')

  // ONLY called from button click — never in useEffect
  const requestLocation = useCallback(() => {
    if (!navigator.geolocation) { setStatus('denied'); return }
    navigator.geolocation.getCurrentPosition(
      (pos) => { setLocation([pos.coords.latitude, pos.coords.longitude]); setStatus('granted') },
      () => setStatus('denied'),
      { timeout: 10000 }
    )
  }, [])

  return { location, status, requestLocation }
}
```

## Anti-patterns

- **Unsolicited geolocation request on page load** — dark pattern + browser permission fatigue
- **10k markers rendered directly** — mobile browsers stall; zoom-level-dependent marker hiding also helps
- **Tile provider not in privacy policy** — compliance miss (GDPR / KVKK / CCPA declare third-party data recipients)
- **Home-address events** — organizer's address becomes public; use venue aliases
- **Map without non-map fallback** — screen-reader users get nothing

## Integration

- `docs/runtime/sector-packs.md §member-gated-community-platform` — event-map is part of community pack
- `docs/governance/product-surface-split.md` — event-map is a public surface (visible before auth in most products)
- `docs/runtime/anti-patterns.md` — tile provider undocumented = schema drift / compliance drift variant
- `docs/runtime/rule-packs/api-security.md` — coordinates in API responses need sanity checks (no precision leak)

## Canonical footer

Authoritative as of Ulak OS **v2.2.0**. Evidence base: community-platform.com `components/EventMap.tsx` (Leaflet + react-leaflet + event RSVP flow). Added in v2.2.0 cross-project pattern absorption pass.
