import { useState, useEffect } from 'react'
import { initializeApp } from 'firebase/app'
import { getAuth, onAuthStateChanged } from 'firebase/auth'
import { firebaseConfig } from './config/firebase'
import Login from './components/Login'
import Dashboard from './components/Dashboard'
import { MantineProvider } from '@mantine/core'
import { Notifications } from '@mantine/notifications'
import '@mantine/core/styles.css'
import '@mantine/notifications/styles.css'
import './App.css'

// Initialize Firebase
const app = initializeApp(firebaseConfig)
const auth = getAuth(app)

function App() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user)
      setLoading(false)
    })

    return () => unsubscribe()
  }, [])

  if (loading) {
    return (
      <MantineProvider>
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center', 
          alignItems: 'center', 
          height: '100vh',
          fontSize: '18px'
        }}>
          Loading...
        </div>
      </MantineProvider>
    )
  }

  return (
    <MantineProvider>
      <Notifications />
      {user ? <Dashboard /> : <Login />}
    </MantineProvider>
  )
}

export default App
