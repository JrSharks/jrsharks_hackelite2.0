import { useState } from 'react'
import { 
  Container, 
  Paper, 
  TextInput, 
  PasswordInput, 
  Button, 
  Title, 
  Text,
  Box,
  Alert,
  Group 
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth'
import { IconAccessible, IconAlertCircle } from '@tabler/icons-react'

function Login() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const auth = getAuth()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      await signInWithEmailAndPassword(auth, email, password)
      notifications.show({
        title: 'Success',
        message: 'Signed in successfully!',
        color: 'green',
      })
    } catch (error) {
      console.error('Login error:', error)
      setError(getErrorMessage(error))
      notifications.show({
        title: 'Error',
        message: getErrorMessage(error),
        color: 'red',
      })
    } finally {
      setLoading(false)
    }
  }

  const getErrorMessage = (error) => {
    switch (error.code) {
      case 'auth/user-not-found':
        return 'No account found with this email address.'
      case 'auth/wrong-password':
        return 'Incorrect password.'
      case 'auth/invalid-email':
        return 'Invalid email address.'
      case 'auth/user-disabled':
        return 'This account has been disabled.'
      case 'auth/too-many-requests':
        return 'Too many failed attempts. Please try again later.'
      case 'auth/invalid-credential':
        return 'Invalid email or password.'
      default:
        return 'An error occurred during sign in. Please try again.'
    }
  }

  return (
    <Container size="xs" style={{ 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center', 
      minHeight: '100vh' 
    }}>
      <Paper withBorder shadow="md" p={30} radius="md" style={{ width: '100%' }}>
        <Box ta="center" mb={30}>
          <Group justify="center" mb={10}>
            <IconAccessible size={48} color="#2E7D32" />
          </Group>
          <Title order={2} c="#2E7D32">
            AccessAble Admin
          </Title>
          <Text c="dimmed" size="sm">
            Content Management & Moderation Panel
          </Text>
        </Box>

        {error && (
          <Alert 
            icon={<IconAlertCircle size={16} />} 
            color="red" 
            mb={15}
            variant="light"
          >
            {error}
          </Alert>
        )}

        <form onSubmit={handleSubmit}>
          <TextInput
            label="Email"
            placeholder="Enter your admin email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            mb={15}
            type="email"
          />
          
          <PasswordInput
            label="Password"
            placeholder="Enter your password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            mb={20}
          />
          
          <Button 
            type="submit" 
            fullWidth 
            loading={loading}
            size="md"
            style={{ backgroundColor: '#2E7D32' }}
          >
            Sign In
          </Button>
        </form>

        <Box mt={20} ta="center">
          <Text size="xs" c="dimmed">
            Admin access only. Contact system administrator for account access.
          </Text>
        </Box>
      </Paper>
    </Container>
  )
}

export default Login