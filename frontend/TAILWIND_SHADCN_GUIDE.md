# Tailwind CSS + shadcn/ui Guide

"Use high-fidelity, copy-paste component libraries to polish the look in minutes."

---

## Why This Stack

- **Tailwind**: Utility-first CSS — no custom CSS files, fast iteration
- **shadcn/ui**: Copy-paste React components built on Radix UI + Tailwind
- **Avoid raw CSS**: It's slower to write, harder to maintain, and inconsistent across teammates

---

## Setup: Tailwind in Vite

### Install

```bash
npm install -D tailwindcss @tailwindcss/vite
```

### Configure

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
```

```css
/* src/index.css */
@import "tailwindcss";
```

### Use

```jsx
function App() {
  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <h1 className="text-3xl font-bold text-gray-900">
        Hello World
      </h1>
      <p className="mt-2 text-gray-600">
        This is styled with Tailwind.
      </p>
    </div>
  )
}
```

---

## Setup: shadcn/ui

### Initialize

```bash
npx shadcn@latest init
```

Follow the prompts:
- Style: Default
- Base color: Neutral
- CSS file: `src/index.css`

### Add components

```bash
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
```

Components appear in `src/components/ui/`.

### Use

```jsx
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'

function App() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>My App</CardTitle>
      </CardHeader>
      <CardContent>
        <Input placeholder="Enter something..." />
        <Button className="mt-4">Submit</Button>
      </CardContent>
    </Card>
  )
}
```

---

## Common Components

### Button

```jsx
import { Button } from '@/components/ui/button'

<Button>Default</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button size="sm">Small</Button>
<Button size="lg">Large</Button>
```

### Card

```jsx
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
    <CardDescription>Description</CardDescription>
  </CardHeader>
  <CardContent>
    Content goes here
  </CardContent>
</Card>
```

### Input

```jsx
import { Input } from '@/components/ui/input'

<Input placeholder="Email" type="email" />
```

### Dialog (Modal)

```jsx
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'

<Dialog>
  <DialogTrigger asChild>
    <Button>Open</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Modal Title</DialogTitle>
    </DialogHeader>
    <p>Modal content here</p>
  </DialogContent>
</Dialog>
```

### Table

```jsx
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'

<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Email</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    <TableRow>
      <TableCell>Alice</TableCell>
      <TableCell>alice@example.com</TableCell>
    </TableRow>
  </TableBody>
</Table>
```

---

## Theming

### Dark mode

```jsx
// Add to <html> tag
<html className="dark">
```

### Custom colors

```css
/* src/index.css */
@import "tailwindcss";

@theme {
  --color-primary: #3b82f6;
  --color-secondary: #6b7280;
}
```

```jsx
<Button className="bg-primary text-white">Custom color</Button>
```

---

## Quick Styling Reference

### Layout

```jsx
<div className="flex items-center justify-between">
<div className="grid grid-cols-3 gap-4">
<div className="flex flex-col space-y-2">
```

### Spacing

```jsx
<div className="p-4">        {/* padding */}
<div className="m-2">        {/* margin */}
<div className="gap-4">      {/* gap in flex/grid */}
```

### Typography

```jsx
<h1 className="text-3xl font-bold text-gray-900">
<p className="text-sm text-gray-500">
<span className="font-mono text-xs">
```

### Colors

```jsx
<div className="bg-white text-black">
<div className="bg-blue-500 text-white">
<div className="border border-gray-200">
```

### Responsive

```jsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
<div className="hidden md:block">
```

---

## Dashboard Layout Patterns

### Stat cards grid

```jsx
<div className="grid grid-cols-3 gap-4">
  <div className="bg-white rounded-lg shadow p-6 text-center">
    <div className="text-3xl font-bold text-blue-600">{stats.total}</div>
    <div className="text-sm text-gray-500 mt-1">Total Items</div>
  </div>
  <div className="bg-white rounded-lg shadow p-6 text-center">
    <div className="text-3xl font-bold text-green-600">{stats.active}</div>
    <div className="text-sm text-gray-500 mt-1">Active</div>
  </div>
  <div className="bg-white rounded-lg shadow p-6 text-center">
    <div className="text-3xl font-bold text-yellow-600">{stats.pending}</div>
    <div className="text-sm text-gray-500 mt-1">Pending</div>
  </div>
</div>
```

### Header with nav and user info

```jsx
<header className="bg-white shadow-sm">
  <div className="max-w-4xl mx-auto px-4 py-3 flex justify-between items-center">
    <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>
    <div className="flex items-center gap-4">
      <a href="/dashboard" className="text-sm text-blue-600 hover:underline">Dashboard</a>
      <span className="text-sm text-gray-600">{user.email}</span>
      <button onClick={logout} className="text-sm text-red-600 hover:underline">Logout</button>
    </div>
  </div>
</header>
```

### List with dividers

```jsx
<div className="bg-white rounded-lg shadow p-6">
  <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Items</h2>
  <div className="divide-y">
    {items.map(item => (
      <div key={item.id} className="py-3 flex justify-between items-center">
        <span className="font-medium text-gray-800">{item.title}</span>
        <span className="text-sm text-gray-400">{item.date}</span>
      </div>
    ))}
  </div>
</div>
```

---

## Common Gotchas

| Issue | Fix |
|---|---|
| Styles not applying | Ensure `@import "tailwindcss"` is in index.css |
| shadcn components not found | Run `npx shadcn@latest add [component]` |
| Dark mode not working | Add `className="dark"` to `<html>` element |
| Missing `@/` path alias | Check `vite.config.js` has path alias configured |
