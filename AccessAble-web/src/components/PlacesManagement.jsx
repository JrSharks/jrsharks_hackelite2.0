import { useState, useEffect } from 'react'
import { 
  Container, 
  Title, 
  Text,
  Card,
  Table,
  Button,
  Badge,
  Group,
  ActionIcon,
  Modal,
  Stack,
  Loader,
  Alert,
  Pagination,
  TextInput,
  Chip,
  Image,
  SimpleGrid
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import { 
  IconCheck, 
  IconX, 
  IconEye, 
  IconTrash, 
  IconSearch,
  IconRefresh,
  IconAlertCircle,
  IconMapPin,
  IconAccessible
} from '@tabler/icons-react'
import { placeService } from '../services'

function PlacesManagement() {
  const [places, setPlaces] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [selectedPlace, setSelectedPlace] = useState(null)
  const [modalOpened, setModalOpened] = useState(false)
  const [viewMode, setViewMode] = useState('pending') // 'pending' or 'all'
  const [currentPage, setCurrentPage] = useState(1)
  const [searchQuery, setSearchQuery] = useState('')
  const pageSize = 10

  useEffect(() => {
    loadPlaces()
  }, [viewMode, currentPage])

  const loadPlaces = async () => {
    try {
      setLoading(true)
      setError(null)
      
      if (viewMode === 'pending') {
        const data = await placeService.getPendingPlaces()
        setPlaces(data)
      } else {
        const offset = (currentPage - 1) * pageSize
        const data = await placeService.getAllPlaces(true, pageSize, offset)
        setPlaces(data)
      }
    } catch (err) {
      setError('Failed to load places')
      notifications.show({
        title: 'Error',
        message: 'Failed to load places',
        color: 'red',
      })
    } finally {
      setLoading(false)
    }
  }

  const handleApprovePlace = async (id) => {
    try {
      await placeService.approvePlace(id)
      notifications.show({
        title: 'Success',
        message: 'Place approved successfully',
        color: 'green',
      })
      loadPlaces()
    } catch (err) {
      notifications.show({
        title: 'Error',
        message: 'Failed to approve place',
        color: 'red',
      })
    }
  }

  const handleDeletePlace = async (id) => {
    if (!confirm('Are you sure you want to delete this place? This action cannot be undone.')) {
      return
    }

    try {
      await placeService.deletePlace(id)
      notifications.show({
        title: 'Success',
        message: 'Place deleted successfully',
        color: 'green',
      })
      loadPlaces()
    } catch (err) {
      notifications.show({
        title: 'Error',
        message: 'Failed to delete place',
        color: 'red',
      })
    }
  }

  const filteredPlaces = places.filter(place => {
    if (!searchQuery) return true
    const query = searchQuery.toLowerCase()
    return (
      place.name?.toLowerCase().includes(query) ||
      place.description?.toLowerCase().includes(query) ||
      place.category?.toLowerCase().includes(query) ||
      place.address?.toLowerCase().includes(query)
    )
  })

  const getCategoryColor = (category) => {
    const colors = {
      restaurant: 'blue',
      hotel: 'purple',
      shopping: 'green',
      entertainment: 'orange',
      healthcare: 'red',
      education: 'teal',
      transport: 'indigo',
      government: 'gray',
    }
    return colors[category?.toLowerCase()] || 'gray'
  }

  const formatDate = (timestamp) => {
    if (!timestamp) return 'Unknown'
    try {
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp)
      return date.toLocaleDateString()
    } catch {
      return 'Unknown'
    }
  }

  const getAccessibilityFeatures = (features) => {
    if (!features) return []
    return Object.entries(features)
      .filter(([key, value]) => value === true)
      .map(([key]) => {
        const labels = {
          wheelchairAccessible: 'Wheelchair',
          brailleSupport: 'Braille',
          hearingAssistance: 'Hearing',
          visualAssistance: 'Visual',
          accessibleParking: 'Parking',
          accessibleRestroom: 'Restroom',
          elevatorAccess: 'Elevator',
          rampAccess: 'Ramp'
        }
        return labels[key] || key
      })
  }

  if (loading) {
    return (
      <Container size="xl">
        <Group justify="center" mt="xl">
          <Loader size="lg" />
          <Text>Loading places...</Text>
        </Group>
      </Container>
    )
  }

  if (error) {
    return (
      <Container size="xl">
        <Alert 
          icon={<IconAlertCircle size={16} />} 
          color="red" 
          title="Error"
          mt="xl"
        >
          {error}
          <Button variant="light" size="sm" mt="sm" onClick={loadPlaces}>
            Retry
          </Button>
        </Alert>
      </Container>
    )
  }

  return (
    <Container size="xl">
      <Group justify="space-between" mb="lg">
        <div>
          <Title order={2}>Places Management</Title>
          <Text c="dimmed">Review and approve place submissions</Text>
        </div>
        <Group>
          <Button 
            variant={viewMode === 'pending' ? 'filled' : 'light'}
            onClick={() => setViewMode('pending')}
          >
            Pending
          </Button>
          <Button 
            variant={viewMode === 'all' ? 'filled' : 'light'}
            onClick={() => setViewMode('all')}
          >
            All Places
          </Button>
          <Button 
            variant="light" 
            leftSection={<IconRefresh size={16} />}
            onClick={loadPlaces}
          >
            Refresh
          </Button>
        </Group>
      </Group>

      <Card withBorder>
        <Group mb="md">
          <TextInput
            placeholder="Search places..."
            leftSection={<IconSearch size={16} />}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{ flex: 1 }}
          />
        </Group>

        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Name</Table.Th>
              <Table.Th>Category</Table.Th>
              <Table.Th>Address</Table.Th>
              <Table.Th>Features</Table.Th>
              <Table.Th>Status</Table.Th>
              <Table.Th>Submitted</Table.Th>
              <Table.Th>Actions</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {filteredPlaces.length === 0 ? (
              <Table.Tr>
                <Table.Td colSpan={7}>
                  <Text ta="center" c="dimmed" py="xl">
                    No places found
                  </Text>
                </Table.Td>
              </Table.Tr>
            ) : (
              filteredPlaces.map((place) => (
                <Table.Tr key={place.id}>
                  <Table.Td>
                    <div>
                      <Text fw={500}>{place.name}</Text>
                      <Text size="sm" c="dimmed" truncate style={{ maxWidth: '200px' }}>
                        {place.description}
                      </Text>
                    </div>
                  </Table.Td>
                  <Table.Td>
                    <Badge color={getCategoryColor(place.category)} variant="light">
                      {place.category || 'Other'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Text size="sm" truncate style={{ maxWidth: '150px' }}>
                      {place.address}
                    </Text>
                  </Table.Td>
                  <Table.Td>
                    <Group gap={4}>
                      {getAccessibilityFeatures(place.accessibilityFeatures).slice(0, 2).map((feature) => (
                        <Chip key={feature} size="xs" checked={false}>
                          {feature}
                        </Chip>
                      ))}
                      {getAccessibilityFeatures(place.accessibilityFeatures).length > 2 && (
                        <Text size="xs" c="dimmed">
                          +{getAccessibilityFeatures(place.accessibilityFeatures).length - 2}
                        </Text>
                      )}
                    </Group>
                  </Table.Td>
                  <Table.Td>
                    <Badge 
                      color={place.isApproved ? 'green' : 'orange'} 
                      variant="light"
                    >
                      {place.isApproved ? 'Approved' : 'Pending'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Text size="sm">{formatDate(place.createdAt)}</Text>
                  </Table.Td>
                  <Table.Td>
                    <Group gap="xs">
                      <ActionIcon 
                        variant="light" 
                        color="blue"
                        onClick={() => {
                          setSelectedPlace(place)
                          setModalOpened(true)
                        }}
                      >
                        <IconEye size={16} />
                      </ActionIcon>
                      {!place.isApproved && (
                        <ActionIcon 
                          variant="light" 
                          color="green"
                          onClick={() => handleApprovePlace(place.id)}
                        >
                          <IconCheck size={16} />
                        </ActionIcon>
                      )}
                      <ActionIcon 
                        variant="light" 
                        color="red"
                        onClick={() => handleDeletePlace(place.id)}
                      >
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Group>
                  </Table.Td>
                </Table.Tr>
              ))
            )}
          </Table.Tbody>
        </Table>

        {viewMode === 'all' && (
          <Group justify="center" mt="md">
            <Pagination 
              value={currentPage} 
              onChange={setCurrentPage}
              total={Math.ceil(places.length / pageSize)}
            />
          </Group>
        )}
      </Card>

      <Modal 
        opened={modalOpened} 
        onClose={() => setModalOpened(false)}
        title="Place Details"
        size="lg"
      >
        {selectedPlace && (
          <Stack>
            <SimpleGrid cols={2}>
              <div>
                <Text fw={500}>Name</Text>
                <Text c="dimmed">{selectedPlace.name}</Text>
              </div>
              
              <div>
                <Text fw={500}>Category</Text>
                <Badge color={getCategoryColor(selectedPlace.category)} variant="light">
                  {selectedPlace.category || 'Other'}
                </Badge>
              </div>
            </SimpleGrid>
            
            <div>
              <Text fw={500}>Description</Text>
              <Text c="dimmed">{selectedPlace.description}</Text>
            </div>
            
            <div>
              <Text fw={500}>Address</Text>
              <Group>
                <IconMapPin size={16} color="gray" />
                <Text c="dimmed">{selectedPlace.address}</Text>
              </Group>
            </div>
            
            <div>
              <Text fw={500}>Coordinates</Text>
              <Text c="dimmed">
                {selectedPlace.coordinates?.latitude}, {selectedPlace.coordinates?.longitude}
              </Text>
            </div>
            
            <div>
              <Text fw={500}>Accessibility Features</Text>
              <Group mt="xs">
                <IconAccessible size={16} color="green" />
                {getAccessibilityFeatures(selectedPlace.accessibilityFeatures).map((feature) => (
                  <Chip key={feature} checked={true} variant="filled">
                    {feature}
                  </Chip>
                ))}
              </Group>
            </div>
            
            {selectedPlace.photos && selectedPlace.photos.length > 0 && (
              <div>
                <Text fw={500}>Photos</Text>
                <SimpleGrid cols={3} mt="xs">
                  {selectedPlace.photos.slice(0, 6).map((photo, index) => (
                    <Image 
                      key={index}
                      src={photo} 
                      alt={`Photo ${index + 1}`}
                      height={80}
                      radius="sm"
                      fit="cover"
                    />
                  ))}
                </SimpleGrid>
              </div>
            )}
            
            <SimpleGrid cols={2}>
              <div>
                <Text fw={500}>Status</Text>
                <Badge 
                  color={selectedPlace.isApproved ? 'green' : 'orange'} 
                  variant="light"
                >
                  {selectedPlace.isApproved ? 'Approved' : 'Pending Approval'}
                </Badge>
              </div>
              
              <div>
                <Text fw={500}>Submitted</Text>
                <Text c="dimmed">{formatDate(selectedPlace.createdAt)}</Text>
              </div>
            </SimpleGrid>
            
            <div>
              <Text fw={500}>Reviews</Text>
              <Text c="dimmed">
                {selectedPlace.reviews?.length || 0} reviews • 
                Average rating: {selectedPlace.averageRating?.toFixed(1) || 'N/A'}
              </Text>
            </div>
            
            <Group justify="flex-end" mt="md">
              {!selectedPlace.isApproved && (
                <Button 
                  color="green" 
                  leftSection={<IconCheck size={16} />}
                  onClick={() => {
                    handleApprovePlace(selectedPlace.id)
                    setModalOpened(false)
                  }}
                >
                  Approve Place
                </Button>
              )}
              <Button variant="outline" onClick={() => setModalOpened(false)}>
                Close
              </Button>
            </Group>
          </Stack>
        )}
      </Modal>
    </Container>
  )
}

export default PlacesManagement