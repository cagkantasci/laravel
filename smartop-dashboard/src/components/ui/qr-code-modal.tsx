import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { QRCodeSVG } from 'qrcode.react'
import { Download } from 'lucide-react'

interface QRCodeModalProps {
  isOpen: boolean
  onClose: () => void
  machine: {
    id: number
    name: string
    qr_code?: string
    serial_number?: string
  }
}

export function QRCodeModal({ isOpen, onClose, machine }: QRCodeModalProps) {
  const qrValue = machine.qr_code || `MACHINE_${machine.id}`

  const handleDownload = () => {
    const svg = document.getElementById('machine-qr-code')
    if (!svg) return

    const svgData = new XMLSerializer().serializeToString(svg)
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const img = new Image()

    img.onload = () => {
      canvas.width = 512
      canvas.height = 512
      ctx?.drawImage(img, 0, 0, 512, 512)
      const pngFile = canvas.toDataURL('image/png')
      const downloadLink = document.createElement('a')
      downloadLink.download = `qr-${machine.serial_number || machine.id}.png`
      downloadLink.href = pngFile
      downloadLink.click()
    }

    img.src = 'data:image/svg+xml;base64,' + btoa(svgData)
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Makine QR Kodu</DialogTitle>
          <DialogDescription>
            {machine.name} - {machine.serial_number}
          </DialogDescription>
        </DialogHeader>
        <div className="flex flex-col items-center space-y-4 py-4">
          <div className="bg-white p-4 rounded-lg border-2 border-gray-200">
            <QRCodeSVG
              id="machine-qr-code"
              value={qrValue}
              size={256}
              level="H"
              includeMargin={true}
            />
          </div>
          <div className="text-sm text-gray-600 text-center">
            <p className="font-mono">{qrValue}</p>
            <p className="mt-2 text-xs">
              Mobil uygulamadan bu QR kodu okutarak makineye hızlıca erişebilirsiniz.
            </p>
          </div>
        </div>
        <div className="flex justify-end space-x-2">
          <Button variant="outline" onClick={onClose}>
            Kapat
          </Button>
          <Button onClick={handleDownload}>
            <Download className="h-4 w-4 mr-2" />
            İndir
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
