import { redirect } from 'next/navigation'

export default function Home() {
  // Ana sayfa dashboard'a yönlendirir
  redirect('/dashboard')
}
