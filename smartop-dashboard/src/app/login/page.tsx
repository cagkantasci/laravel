'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useLogin } from '@/hooks/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Eye, EyeOff, Loader2, Shield } from 'lucide-react'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')

  const loginMutation = useLogin()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!email || !password) {
      setError('Email ve şifre gereklidir')
      return
    }

    try {
      const result = await loginMutation.mutateAsync({
        email,
        password,
      })

      if (result.success) {
        // Store token in localStorage using the same key as API client
        localStorage.setItem('smartop_token', result.data.token)
        localStorage.setItem('user', JSON.stringify(result.data.user))

        // Redirect to dashboard
        router.push('/dashboard')
      } else {
        setError('Giriş başarısız - sunucu yanıtı geçersiz')
      }
    } catch (error: any) {
      console.error('Login error:', error)
      setError(error.response?.data?.message || 'Giriş başarısız')
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className="flex items-center justify-center mb-4">
            <div className="bg-blue-600 p-3 rounded-full">
              <Shield className="h-8 w-8 text-white" />
            </div>
          </div>
          <CardTitle className="text-2xl font-bold text-center">SmartOp Admin</CardTitle>
          <CardDescription className="text-center">
            Endüstriyel makine kontrol sistemi yönetim paneli
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="admin@smartop.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoComplete="email"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Şifre</Label>
              <div className="relative">
                <Input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  autoComplete="current-password"
                />
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeOff className="h-4 w-4" />
                  ) : (
                    <Eye className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>

            {error && (
              <Alert variant="destructive">
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            <Button
              type="submit"
              className="w-full"
              disabled={loginMutation.isPending}
            >
              {loginMutation.isPending ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Giriş yapılıyor...
                </>
              ) : (
                'Giriş Yap'
              )}
            </Button>
          </form>

          <div className="mt-6 space-y-2">
            <div className="text-sm text-gray-600">
              <strong>Test Kullanıcıları:</strong>
            </div>
            <div className="text-xs text-gray-500 space-y-1">
              <div><strong>Admin:</strong> admin@smartop.com / password</div>
              <div><strong>Manager:</strong> manager@smartop.com / password</div>
              <div><strong>Operator:</strong> operator@smartop.com / password</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}