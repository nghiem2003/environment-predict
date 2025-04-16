import React from 'react';
import { MapContainer, TileLayer, Circle, Popup } from 'react-leaflet';
import { LatLng } from 'leaflet';
import 'leaflet/dist/leaflet.css'; // Import Leaflet CSS

const MapView = ({ latitude, longitude, result, area }) => {
  const center = new LatLng(latitude, longitude);
  const color = result == 1 ? 'blue' : result == 0 ? 'yellow' : 'red'
  return (
    <div style={{ width: '100%', height: '400px' }}>
      <MapContainer
        center={center}
        zoom={12}
        style={{ width: '100%', height: '100%' }}
      >
        {/* OpenStreetMap TileLayer */}
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        />
        {/* Circle Marker */}
        <Circle
          center={center}
          radius={area} // Example radius in meters
          pathOptions={{
            fillColor: color,
            fillOpacity: 0.2,
            color: color,
            opacity: 0.5,
          }}
        >
          <Popup>
            <span>
              Location: {latitude}, {longitude}
            </span>
          </Popup>
        </Circle>
      </MapContainer>
    </div>
  );
};

export default MapView;
