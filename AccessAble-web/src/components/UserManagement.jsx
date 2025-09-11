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
  Select,
  Loader,
  Alert,
  Pagination,
  TextInput
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import { 
  IconCheck, 
  IconX, 
  IconEye, 
  IconTrash, 
  IconSearch,
  IconRefresh,
  IconAlertCircle
} from '@tabler/icons-react'
import { userService } from '../services'

function UserManagement() {
  const [users, setUsers] = useState([])
  const [pendingUsers, setPendingUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [selectedUser, setSelectedUser] = useState(null)
  const [modalOpened, setModalOpened] = useState(false)
  const [viewMode, setViewMode] = useState('pending') // 'pending' or 'all'
  const [currentPage, setCurrentPage] = useState(1)
  const [searchQuery, setSearchQuery] = useState('')
  const pageSize = 10

  useEffect(() => {
    loadUsers()
  }, [viewMode, currentPage])

  const loadUsers = async () => {
    try {
      setLoading(true)
      setError(null)
      
      if (viewMode === 'pending') {
        const data = await userService.getPendingUsers()
        setPendingUsers(data)
        setUsers(data)
      } else {
        const offset = (currentPage - 1) * pageSize
        const data = await userService.getAllUsers(pageSize, offset)
        setUsers(data)
      }
    } catch (err) {
      setError('Failed to load users')
      notifications.show({
        title: 'Error',
        message: 'Failed to load users',
        color: 'red',
      })
    } finally {
      setLoading(false)
    }
  }

  const handleApproveUser = async (uid) => {
    try {
      await userService.approveUser(uid)
      notifications.show({
        title: 'Success',
        message: 'User approved successfully',
        color: 'green',
      })
      loadUsers()
    } catch (err) {
      notifications.show({
        title: 'Error',
        message: 'Failed to approve user',
        color: 'red',
      })
    }
  }

  const handleUpdateRole = async (uid, role) => {
    try {
      await userService.updateUserRole(uid, role)
      notifications.show({
        title: 'Success',
        message: 'User role updated successfully',
        color: 'green',
      })
      loadUsers()
      setModalOpened(false)
    } catch (err) {
      notifications.show({
        title: 'Error',
        message: 'Failed to update user role',
        color: 'red',
      })
    }
  }

  const handleDeleteUser = async (uid) => {
    if (!confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
      return
    }

    try {
      await userService.deleteUser(uid)
      notifications.show({
        title: 'Success',
        message: 'User deleted successfully',
        color: 'green',
      })
      loadUsers()
    } catch (err) {
      notifications.show({
        title: 'Error',
        message: 'Failed to delete user',
        color: 'red',
      })
    }
  }

  const filteredUsers = users.filter(user => {
    if (!searchQuery) return true
    const query = searchQuery.toLowerCase()
    return (
      user.fullName?.toLowerCase().includes(query) ||
      user.email?.toLowerCase().includes(query) ||
      user.role?.toLowerCase().includes(query)
    )
  })

  const getRoleBadgeColor = (role) => {
    switch (role) {
      case 'admin': return 'red'
      case 'business': return 'blue'
      case 'caregiver': return 'purple'
      default: return 'gray'
    }
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

  if (loading) {
    return (
      <Container size="xl">
        <Group justify="center" mt="xl">
          <Loader size="lg" />
          <Text>Loading users...</Text>
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
          <Button variant="light" size="sm" mt="sm" onClick={loadUsers}>
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
          <Title order={2}>User Management</Title>
          <Text c="dimmed">Manage user registrations and approvals</Text>
        </div>
        <Group>
          <Select
            value={viewMode}
            onChange={setViewMode}
            data={[
              { value: 'pending', label: 'Pending Users' },
              { value: 'all', label: 'All Users' },
            ]}
          />
          <Button 
            variant="light" 
            leftSection={<IconRefresh size={16} />}
            onClick={loadUsers}
          >
            Refresh
          </Button>
        </Group>
      </Group>

      <Card withBorder>
        <Group mb="md">
          <TextInput
            placeholder="Search users..."
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
              <Table.Th>Email</Table.Th>
              <Table.Th>Role</Table.Th>
              <Table.Th>Status</Table.Th>
              <Table.Th>Registered</Table.Th>
              <Table.Th>Actions</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {filteredUsers.length === 0 ? (
              <Table.Tr>
                <Table.Td colSpan={6}>
                  <Text ta="center" c="dimmed" py="xl">
                    No users found
                  </Text>
                </Table.Td>
              </Table.Tr>
            ) : (
              filteredUsers.map((user) => (
                <Table.Tr key={user.uid}>
                  <Table.Td>
                    <Text fw={500}>{user.fullName || 'No name'}</Text>
                  </Table.Td>
                  <Table.Td>
                    <Text size="sm" c="dimmed">{user.email}</Text>
                  </Table.Td>
                  <Table.Td>
                    <Badge color={getRoleBadgeColor(user.role)} variant="light">
                      {user.role || 'user'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Badge 
                      color={user.isApproved ? 'green' : 'orange'} 
                      variant="light"
                    >
                      {user.isApproved ? 'Approved' : 'Pending'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Text size="sm">{formatDate(user.createdAt)}</Text>
                  </Table.Td>
                  <Table.Td>
                    <Group gap="xs">
                      <ActionIcon 
                        variant="light" 
                        color="blue"
                        onClick={() => {
                          setSelectedUser(user)
                          setModalOpened(true)
                        }}
                      >
                        <IconEye size={16} />
                      </ActionIcon>
                      {!user.isApproved && (
                        <ActionIcon 
                          variant="light" 
                          color="green"
                          onClick={() => handleApproveUser(user.uid)}
                        >
                          <IconCheck size={16} />
                        </ActionIcon>
                      )}
                      <ActionIcon 
                        variant="light" 
                        color="red"
                        onClick={() => handleDeleteUser(user.uid)}
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
              total={Math.ceil(users.length / pageSize)}
            />
          </Group>
        )}
      </Card>

      <Modal 
        opened={modalOpened} 
        onClose={() => setModalOpened(false)}
        title="User Details"
        size="md"
      >
        {selectedUser && (
          <Stack>
            <div>
              <Text fw={500}>Full Name</Text>
              <Text c="dimmed">{selectedUser.fullName || 'No name provided'}</Text>
            </div>
            
            <div>
              <Text fw={500}>Email</Text>
              <Text c="dimmed">{selectedUser.email}</Text>
            </div>
            
            <div>
              <Text fw={500}>Current Role</Text>
              <Badge color={getRoleBadgeColor(selectedUser.role)} variant="light">
                {selectedUser.role || 'user'}
              </Badge>
            </div>
            
            <div>
              <Text fw={500}>Status</Text>
              <Badge 
                color={selectedUser.isApproved ? 'green' : 'orange'} 
                variant="light"
              >
                {selectedUser.isApproved ? 'Approved' : 'Pending Approval'}
              </Badge>
            </div>
            
            <div>
              <Text fw={500}>Registration Date</Text>
              <Text c="dimmed">{formatDate(selectedUser.createdAt)}</Text>
            </div>
            
            <div>
              <Text fw={500}>Contributions</Text>
              <Text c="dimmed">{selectedUser.contributionCount || 0} places added</Text>
            </div>
            
            <Select
              label="Update Role"
              value={selectedUser.role || 'user'}
              onChange={(value) => handleUpdateRole(selectedUser.uid, value)}
              data={[
                { value: 'user', label: 'Regular User' },
                { value: 'caregiver', label: 'Caregiver' },
                { value: 'business', label: 'Business Owner' },
                { value: 'admin', label: 'Administrator' },
              ]}
            />
            
            <Group justify="flex-end" mt="md">
              {!selectedUser.isApproved && (
                <Button 
                  color="green" 
                  leftSection={<IconCheck size={16} />}
                  onClick={() => {
                    handleApproveUser(selectedUser.uid)
                    setModalOpened(false)
                  }}
                >
                  Approve User
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

export default UserManagement