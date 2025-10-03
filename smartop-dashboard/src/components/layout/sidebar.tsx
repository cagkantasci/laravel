'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  Shield,
  LayoutDashboard,
  Users,
  Settings,
  Building2,
  Truck,
  ClipboardList,
  BarChart3,
  CreditCard,
  UserCheck,
  FileText,
  FileCheck,
  Clock
} from 'lucide-react'
import { cn } from '@/lib/utils'

const navigation = [
  {
    name: 'Dashboard',
    href: '/dashboard',
    icon: LayoutDashboard,
    roles: ['admin', 'manager']
  },
  {
    name: 'Şirketler',
    href: '/companies',
    icon: Building2,
    roles: ['admin']
  },
  {
    name: 'Kullanıcılar',
    href: '/users',
    icon: Users,
    roles: ['admin', 'manager']
  },
  {
    name: 'Makineler',
    href: '/machines',
    icon: Truck,
    roles: ['admin', 'manager', 'operator']
  },
  {
    name: 'Kontrol Şablonları',
    href: '/control-templates',
    icon: FileCheck,
    roles: ['admin', 'manager']
  },
  {
    name: 'Kontrol Listeleri',
    href: '/control-lists',
    icon: ClipboardList,
    roles: ['admin', 'manager', 'operator']
  },
  {
    name: 'Çalışma Seansları',
    href: '/work-sessions',
    icon: Clock,
    roles: ['admin', 'manager']
  },
  {
    name: 'Onaylar',
    href: '/approvals',
    icon: UserCheck,
    roles: ['admin', 'manager']
  },
  {
    name: 'Raporlar',
    href: '/reports',
    icon: BarChart3,
    roles: ['admin', 'manager']
  },
  {
    name: 'Fiyatlandırma',
    href: '/pricing',
    icon: CreditCard,
    roles: ['admin']
  },
  {
    name: 'Dökümanlar',
    href: '/docs',
    icon: FileText,
    roles: ['admin', 'manager']
  },
  {
    name: 'Ayarlar',
    href: '/settings',
    icon: Settings,
    roles: ['admin', 'manager']
  }
]

interface SidebarProps {
  userRole?: string
  onClose?: () => void
}

export default function Sidebar({ userRole = 'admin', onClose }: SidebarProps) {
  const pathname = usePathname()

  const filteredNavigation = navigation.filter(item =>
    item.roles.includes(userRole)
  )

  const handleNavClick = () => {
    // Close sidebar on mobile when navigation item is clicked
    if (onClose) {
      onClose()
    }
  }

  return (
    <div className="flex h-full w-64 flex-col bg-slate-900">
      {/* Logo */}
      <div className="flex h-16 items-center px-6">
        <div className="flex items-center space-x-2">
          <Shield className="h-8 w-8 text-blue-400" />
          <span className="text-xl font-bold text-white">SmartOp</span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-4 py-6">
        <ul className="space-y-1">
          {filteredNavigation.map((item) => {
            const isActive = pathname === item.href
            return (
              <li key={item.name}>
                <Link
                  href={item.href}
                  onClick={handleNavClick}
                  className={cn(
                    'flex items-center rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-blue-600 text-white'
                      : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                  )}
                >
                  <item.icon className="mr-3 h-5 w-5" />
                  {item.name}
                </Link>
              </li>
            )
          })}
        </ul>
      </nav>

      {/* User Role Badge */}
      <div className="p-4">
        <div className="rounded-lg bg-slate-800 p-3">
          <div className="text-xs font-medium text-slate-400">Aktif Rol</div>
          <div className="text-sm font-semibold text-white capitalize">
            {userRole === 'admin' ? 'Sistem Yöneticisi' :
             userRole === 'manager' ? 'Şirket Yöneticisi' : 'Operatör'}
          </div>
        </div>
      </div>
    </div>
  )
}