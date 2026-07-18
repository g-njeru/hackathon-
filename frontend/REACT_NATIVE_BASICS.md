# React Native Basics

"You know React — here's what's different."

---

## Key Differences from React Web

| Concept | React (Web) | React Native |
|---|---|---|
| Styling | CSS / Tailwind | `StyleSheet` (no CSS) |
| Layout | `div`, `span`, flexbox | `View`, `Text`, flexbox only |
| Navigation | React Router | React Navigation |
| Images | `<img>` | `<Image>` |
| Lists | `<ul>`, `<ol>` | `<FlatList>`, `<SectionList>` |
| Text input | `<input>`, `<textarea>` | `<TextInput>` |
| Scrolling | `overflow: auto` | `<ScrollView>`, `<FlatList>` |
| Touch | `onClick` | `onPress` |
| DevTools | Browser DevTools | Flipper / React DevTools |

---

## Setup

### With Expo (recommended for hackathons)

```bash
npx create-expo-app@latest mobile
cd mobile
npx expo start
```

Scan the QR code with Expo Go app on your phone.

### Without Expo (bare workflow)

```bash
npx react-native init MobileApp
cd mobileapp
npx react-native run-android  # or run-ios
```

---

## Core Components

### View (replaces div)

```jsx
import { View, StyleSheet } from 'react-native'

<View style={styles.container}>
  <Text>Hello</Text>
</View>

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  }
})
```

### Text (replaces span/p)

```jsx
import { Text } from 'react-native'

<Text style={{ fontSize: 16, fontWeight: 'bold' }}>
  Hello World
</Text>
```

### Image

```jsx
import { Image } from 'react-native'

// Local asset
<Image source={require('./logo.png')} />

// Remote URL
<Image source={{ uri: 'https://example.com/image.png' }} style={{ width: 100, height: 100 }} />
```

### TextInput (replaces input)

```jsx
import { TextInput } from 'react-native'

<TextInput
  placeholder="Enter text"
  value={text}
  onChangeText={setText}
  style={{ borderWidth: 1, padding: 10 }}
/>
```

### TouchableOpacity (replaces button/onClick)

```jsx
import { TouchableOpacity, Text } from 'react-native'

<TouchableOpacity onPress={() => console.log('pressed')}>
  <Text>Click me</Text>
</TouchableOpacity>
```

### FlatList (replaces .map)

```jsx
import { FlatList } from 'react-native'

<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={({ item }) => <Text>{item.title}</Text>}
/>
```

---

## Navigation (React Navigation)

```bash
npx expo install @react-navigation/native @react-navigation/native-stack
npx expo install react-native-screens react-native-safe-area-context
```

```jsx
// App.jsx
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'
import DetailScreen from './screens/DetailScreen'

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Detail" component={DetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  )
}
```

### Navigate

```jsx
// In HomeScreen
function HomeScreen({ navigation }) {
  return (
    <Button
      title="Go to Detail"
      onPress={() => navigation.navigate('Detail', { id: 123 })}
    />
  )
}

// In DetailScreen
function DetailScreen({ route }) {
  const { id } = route.params
  return <Text>ID: {id}</Text>
}
```

---

## StyleSheet

```jsx
import { StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
})
```

**Note**: Only flexbox is supported. No `display: grid`, no `float`, no CSS variables.

---

## Platform-Specific Code

```jsx
import { Platform } from 'react-native'

const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
    },
    android: {
      elevation: 4,
    },
  }),
})
```

---

## Common Patterns

### API calls (same as web)

```javascript
const fetchDocuments = async () => {
  const res = await fetch('http://localhost:8000/documents')
  const data = await res.json()
  setDocuments(data)
}
```

### AsyncStorage (like localStorage)

```bash
npx expo install @react-native-async-storage/async-storage
```

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage'

// Save
await AsyncStorage.setItem('token', 'abc123')

// Load
const token = await AsyncStorage.getItem('token')

// Remove
await AsyncStorage.removeItem('token')
```

### SafeAreaView

```jsx
import { SafeAreaView } from 'react-native'

<SafeAreaView style={{ flex: 1 }}>
  <Text>This content is not hidden by the notch/status bar</Text>
</SafeAreaView>
```

---

## Common Gotchas

| Issue | Fix |
|---|---|
| No CSS files | Use `StyleSheet.create()` |
| No `onClick` | Use `onPress` with `TouchableOpacity` |
| No `<img>` | Use `<Image>` with `source={{ uri }}` |
| No `window` object | Use `Dimensions` API |
| Fonts don't load | Use `expo-font` or bundled fonts |
| API calls fail on device | Use your machine's IP, not `localhost` |
