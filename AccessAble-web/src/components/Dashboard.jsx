import { useState, useEffect } from 'react'
import { 
  AppShell, 
  Text, 
  Button, 
  Group,
  Box,
  Title,
  Container,
  Card,
  SimpleGrid,
  Badge,
  Stack,
  Loader,
  Alert
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import { getAuth, signOut } from 'firebase/auth'
import { 
  IconAccessible, 
  IconUsers, 
  IconMapPin, 
  IconFlag, 
  IconLogout,
  IconDashboard,
  IconSettings,
  IconAlertCircle
} from '@tabler/icons-react'
import { adminService, userService, placeService } from '../services'
import UserManagement from './UserManagement'
import PlacesManagement from './PlacesManagement'
import PlacesMap from './PlacesMap'

function Dashboard() {
  const [activeSection, setActiveSection] = useState('overview')
  const [dashboardData, setDashboardData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const auth = getAuth()

  useEffect(() => {
    loadDashboardData()
  }, [])

  const loadDashboardData = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await adminService.getDashboardStats()
      setDashboardData(data)
    } catch (err) {
      setError('Failed to load dashboard data')
      notifications.show({
        title: 'Error',
        message: 'Failed to load dashboard data',
        color: 'red',
      })
    } finally {
      setLoading(false)
    }
  }

  const handleSignOut = async () => {
    try {
      await signOut(auth)
      notifications.show({
        title: 'Success',
        message: 'Signed out successfully!',
        color: 'green',
      })
    } catch (error) {
      notifications.show({
        title: 'Error',
        message: 'Failed to sign out',
        color: 'red',
      })
    }
  }

  const navItems = [
    { id: 'overview', label: 'Overview', icon: IconDashboard },
    { id: 'users', label: 'User Management', icon: IconUsers },
    { id: 'places', label: 'Places', icon: IconMapPin },
    { id: 'map', label: 'Map View', icon: IconAccessible },
    { id: 'reports', label: 'Reports', icon: IconFlag },
    { id: 'settings', label: 'Settings', icon: IconSettings },
  ]

  const renderContent = () => {
    if (loading) {
      return (
        <Container size="xl">
          <Group justify="center" mt="xl">
            <Loader size="lg" />
            <Text>Loading dashboard data...</Text>
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
            <Button 
              variant="light" 
              size="sm" 
              mt="sm"
              onClick={loadDashboardData}
            >
              Retry
            </Button>
          </Alert>
        </Container>
      )
    }

    switch (activeSection) {
      case 'overview':
        return <OverviewContent data={dashboardData} onRefresh={loadDashboardData} />
      case 'users':
        return <UserManagement />
      case 'places':
        return <PlacesManagement />
      case 'map':
        return <PlacesMap />
      case 'reports':
        return <ReportsContent />
      case 'settings':
        return <SettingsContent />
      default:
        return <OverviewContent data={dashboardData} onRefresh={loadDashboardData} />
    }
  }

  return (
    <AppShell
      navbar={{
        width: 250,
        breakpoint: 'sm',
      }}
      header={{
        height: 70,
      }}
      padding="md"
    >
      <AppShell.Header>
        <Group h="100%" px="md" justify="space-between">
          <Group>
            <IconAccessible size={32} color="#2E7D32" />
            <div>
              <Title order={3} c="#2E7D32">AccessAble Admin</Title>
              <Text size="xs" c="dimmed">Content Management Panel</Text>
            </div>
          </Group>
          <Button 
            variant="light" 
            leftSection={<IconLogout size={16} />}
            onClick={handleSignOut}
            color="red"
          >
            Sign Out
          </Button>
        </Group>
      </AppShell.Header>

      <AppShell.Navbar p="md">
        <Stack gap="xs">
          {navItems.map((item) => (
            <Button
              key={item.id}
              variant={activeSection === item.id ? 'filled' : 'light'}
              justify="flex-start"
              leftSection={<item.icon size={18} />}
              onClick={() => setActiveSection(item.id)}
              style={{ 
                backgroundColor: activeSection === item.id ? '#2E7D32' : 'transparent',
                color: activeSection === item.id ? 'white' : '#2E7D32'
              }}
            >
              {item.label}
            </Button>
          ))}
        </Stack>
      </AppShell.Navbar>

      <AppShell.Main>
        {renderContent()}
      </AppShell.Main>
    </AppShell>
  )
}

function OverviewContent({ data, onRefresh }) {
  if (!data) return null

  const { users, places, overview } = data

  return (
    <Container size="xl">
      <Group justify="space-between" mb="lg">
        <Title order={2}>Dashboard Overview</Title>
        <Button variant="light" onClick={onRefresh}>
          Refresh Data
        </Button>
      </Group>
      
      <SimpleGrid cols={{ base: 1, sm: 2, lg: 4 }} spacing="lg" mb="xl">
        <Card withBorder padding="lg" radius="md">
          <Group justify="space-between">
            <div>
              <Text c="dimmed" size="sm" tt="uppercase" fw={700}>
                Pending Users
              </Text>
              <Text fw={700} size="xl">
                {users?.pendingUsers || 0}
              </Text>
            </div>
            <IconUsers size={32} color="#FF6F00" />
          </Group>
        </Card>

        <Card withBorder padding="lg" radius="md">
          <Group justify="space-between">
            <div>
              <Text c="dimmed" size="sm" tt="uppercase" fw={700}>
                Total Places
              </Text>
              <Text fw={700} size="xl">
                {places?.totalPlaces || 0}
              </Text>
            </div>
            <IconMapPin size={32} color="#2E7D32" />
          </Group>
        </Card>

        <Card withBorder padding="lg" radius="md">
          <Group justify="space-between">
            <div>
              <Text c="dimmed" size="sm" tt="uppercase" fw={700}>
                Pending Places
              </Text>
              <Text fw={700} size="xl">
                {places?.pendingPlaces || 0}
              </Text>
            </div>
            <IconMapPin size={32} color="#FF6F00" />
          </Group>
        </Card>

        <Card withBorder padding="lg" radius="md">
          <Group justify="space-between">
            <div>
              <Text c="dimmed" size="sm" tt="uppercase" fw={700}>
                Total Users
              </Text>
              <Text fw={700} size="xl">
                {users?.totalUsers || 0}
              </Text>
            </div>
            <IconUsers size={32} color="#2E7D32" />
          </Group>
        </Card>
      </SimpleGrid>

      <SimpleGrid cols={{ base: 1, lg: 2 }} spacing="lg">
        <Card withBorder padding="lg" radius="md">
          <Title order={4} mb="md">System Status</Title>
          <Stack gap="sm">
            <Group justify="space-between">
              <Text>Backend API</Text>
              <Badge color="green" variant="light">Healthy</Badge>
            </Group>
            <Group justify="space-between">
              <Text>Firebase Services</Text>
              <Badge color="green" variant="light">Connected</Badge>
            </Group>
            <Group justify="space-between">
              <Text>Total Pending Approvals</Text>
              <Badge color="orange" variant="light">
                {(users?.pendingUsers || 0) + (places?.pendingPlaces || 0)}
              </Badge>
            </Group>
          </Stack>
        </Card>

        <Card withBorder padding="lg" radius="md">
          <Title order={4} mb="md">Quick Actions</Title>
          <Stack gap="sm">
            <Button 
              variant="light" 
              fullWidth 
              leftSection={<IconUsers size={16} />}
              onClick={() => window.location.hash = '#users'}
            >
              Manage Users ({users?.pendingUsers || 0} pending)
            </Button>
            <Button 
              variant="light" 
              fullWidth 
              leftSection={<IconMapPin size={16} />}
              onClick={() => window.location.hash = '#places'}
            >
              Manage Places ({places?.pendingPlaces || 0} pending)
            </Button>
            <Button 
              variant="light" 
              fullWidth 
              leftSection={<IconFlag size={16} />}
              onClick={() => window.location.hash = '#reports'}
            >
              Review Reports
            </Button>
          </Stack>
        </Card>
      </SimpleGrid>
    </Container>
  )
}

function UserManagementContent() {
  return <UserManagement />
}

function PlacesContent() {
  return <PlacesManagement />
}

function ReportsContent() {
  return (
    <Container size="xl">
      <Title order={2} mb="lg">Reports & Moderation</Title>
      <Text c="dimmed">Review flagged content and user reports</Text>
      <Card withBorder mt="lg" p="lg">
        <Text>Reports management interface will be implemented here...</Text>
      </Card>
    </Container>
  )
}

function SettingsContent() {
  return (
    <Container size="xl">
      <Title order={2} mb="lg">System Settings</Title>
      <Text c="dimmed">Configure system settings and preferences</Text>
      <Card withBorder mt="lg" p="lg">
        <Text>Settings interface will be implemented here...</Text>
      </Card>
    </Container>
  )
}

export default Dashboard