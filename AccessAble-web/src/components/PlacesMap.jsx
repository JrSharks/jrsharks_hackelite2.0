import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { Box, Card, Group, Text, Badge, Button, Modal } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import api from '../services/api';
import 'leaflet/dist/leaflet.css';

// Fix for default markers in react-leaflet
import L from 'leaflet';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

const PlacesMap = () => {
  const [places, setPlaces] = useState([]);
  const [selectedPlace, setSelectedPlace] = useState(null);
  const [loading, setLoading] = useState(true);
  const [opened, { open, close }] = useDisclosure(false);

  useEffect(() => {
    fetchPlaces();
  }, []);

  const fetchPlaces = async () => {
    try {
      setLoading(true);
      const response = await api.get('/places/map-data');
      setPlaces(response.data);
    } catch (error) {
      console.error('Error fetching places:', error);
      // Fallback to regular places endpoint
      try {
        const response = await api.get('/places?approved=true');
        setPlaces(response.data);
      } catch (fallbackError) {
        console.error('Error fetching places (fallback):', fallbackError);
      }
    } finally {
      setLoading(false);
    }
  };

  const getMarkerColor = (place) => {
    const features = place.accessibilityFeatures || {};
    
    // Green for fully accessible
    if (features.wheelchairAccessible && features.accessibleRestroom) {
      return '#28a745';
    }
    
    // Orange for partially accessible
    if (Object.values(features).some(value => value === true)) {
      return '#fd7e14';
    }
    
    // Red for limited accessibility
    return '#dc3545';
  };

  const createCustomIcon = (place) => {
    const color = getMarkerColor(place);
    
    return L.divIcon({
      html: `
        <div style="
          background-color: ${color};
          width: 25px;
          height: 25px;
          border-radius: 50% 50% 50% 0;
          border: 3px solid white;
          transform: rotate(-45deg);
          box-shadow: 0 2px 4px rgba(0,0,0,0.3);
        ">
          <div style="
            transform: rotate(45deg);
            text-align: center;
            line-height: 19px;
            color: white;
            font-size: 12px;
            font-weight: bold;
          ">📍</div>
        </div>
      `,
      className: 'custom-marker',
      iconSize: [25, 25],
      iconAnchor: [12, 24]
    });
  };

  const showPlaceDetails = (place) => {
    setSelectedPlace(place);
    open();
  };

  const getAccessibilityBadges = (features) => {
    const badges = [];
    const featureNames = {
      wheelchairAccessible: 'Wheelchair',
      brailleSupport: 'Braille',
      hearingAssistance: 'Hearing',
      visualAssistance: 'Visual',
      accessibleParking: 'Parking',
      accessibleRestroom: 'Restroom',
      elevatorAccess: 'Elevator',
      rampAccess: 'Ramp',
    };

    Object.entries(features || {}).forEach(([key, value]) => {
      if (value) {
        badges.push(
          <Badge key={key} color="green" size="sm">
            {featureNames[key] || key}
          </Badge>
        );
      }
    });

    return badges;
  };

  if (loading) {
    return (
      <Box ta="center" p="xl">
        <Text>Loading map...</Text>
      </Box>
    );
  }

  return (
    <>
      <Card shadow="sm" padding="lg" radius="md" withBorder>
        <Card.Section>
          <Box h={500}>
            <MapContainer
              center={[37.7749, -122.4194]}
              zoom={13}
              style={{ height: '100%', width: '100%' }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              
              {places.map((place) => (
                <Marker
                  key={place.id}
                  position={[
                    place.coordinates?.latitude || 0,
                    place.coordinates?.longitude || 0
                  ]}
                  icon={createCustomIcon(place)}
                >
                  <Popup>
                    <Box w={250}>
                      <Text fw={500} size="sm" mb="xs">
                        {place.name}
                      </Text>
                      <Text size="xs" c="dimmed" mb="xs">
                        {place.category}
                      </Text>
                      <Text size="xs" mb="xs">
                        {place.address}
                      </Text>
                      <Group gap="xs" mb="xs">
                        {getAccessibilityBadges(place.accessibilityFeatures).slice(0, 3)}
                      </Group>
                      <Button
                        size="xs"
                        variant="light"
                        onClick={() => showPlaceDetails(place)}
                      >
                        View Details
                      </Button>
                    </Box>
                  </Popup>
                </Marker>
              ))}
            </MapContainer>
          </Box>
        </Card.Section>
        
        <Group justify="space-between" mt="md">
          <Text size="sm" c="dimmed">
            {places.length} accessible places shown
          </Text>
          <Group gap="xs">
            <Group gap={5}>
              <Box w={12} h={12} bg="#28a745" style={{ borderRadius: '50%' }} />
              <Text size="xs">Fully Accessible</Text>
            </Group>
            <Group gap={5}>
              <Box w={12} h={12} bg="#fd7e14" style={{ borderRadius: '50%' }} />
              <Text size="xs">Partially Accessible</Text>
            </Group>
            <Group gap={5}>
              <Box w={12} h={12} bg="#dc3545" style={{ borderRadius: '50%' }} />
              <Text size="xs">Limited Accessibility</Text>
            </Group>
          </Group>
        </Group>
      </Card>

      {/* Place Details Modal */}
      <Modal
        opened={opened}
        onClose={close}
        title="Place Details"
        size="md"
      >
        {selectedPlace && (
          <Box>
            <Text fw={600} size="lg" mb="xs">
              {selectedPlace.name}
            </Text>
            <Text c="dimmed" mb="md">
              {selectedPlace.category}
            </Text>
            
            <Text fw={500} mb="xs">Address:</Text>
            <Text mb="md">{selectedPlace.address}</Text>
            
            {selectedPlace.description && (
              <>
                <Text fw={500} mb="xs">Description:</Text>
                <Text mb="md">{selectedPlace.description}</Text>
              </>
            )}
            
            <Text fw={500} mb="xs">Accessibility Features:</Text>
            <Group gap="xs" mb="md">
              {getAccessibilityBadges(selectedPlace.accessibilityFeatures)}
            </Group>
            
            {selectedPlace.reviews && selectedPlace.reviews.length > 0 && (
              <>
                <Text fw={500} mb="xs">Reviews:</Text>
                <Text c="dimmed" size="sm">
                  {selectedPlace.reviews.length} review(s) • 
                  Average rating: {selectedPlace.averageRating?.toFixed(1) || 'N/A'}/5
                </Text>
              </>
            )}
          </Box>
        )}
      </Modal>
    </>
  );
};

export default PlacesMap;