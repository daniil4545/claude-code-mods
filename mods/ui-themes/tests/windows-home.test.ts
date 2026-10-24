import { test, expect } from 'claude-code/testing'

// #4: Windows sets USERPROFILE, not HOME; the themes folder must not land at the drive root.
function fakeFs(files: Record<string, string>, on: any, env: Record<string, string>) {
  on('env.get', ($: any, e: any) => ({ value: env[e.name] }))
  on('fs.exists', ($: any, e: any) => ({ value: e.path in files || String(e.path).includes('/statusline/') }))
  on('fs.read', ($: any, e: any) => {
    if (String(e.path).includes('/statusline/')) return { value: '#!/usr/bin/env bash\n' }
    const v = files[e.path]
    return v === undefined ? { deny: 'ENOENT' } : { value: v }
  })
  on('fs.write', ($: any, e: any) => { files[e.path] = e.text; return { value: undefined } })
  on('fs.list', () => ({ value: [] }))
  on('command.register', () => ({ value: undefined }))
  on('session.start', () => ({ cwd: 'C:/work' }) as any)
  on('ui.invalidate', () => ({ value: undefined }))
  on('ui.toast', () => ({ value: undefined }))
}

test('without HOME, the themes folder is under USERPROFILE', async ($, on) => {
  const files: Record<string, string> = {}
  fakeFs(files, on, { USERPROFILE: 'C:\\Users\\alex' })
  await $.session.start({ source: 'startup', cwd: 'C:/work' } as any)
  // the test runner resolves non-POSIX paths against its own cwd, so match the tail
  const written = Object.keys(files)
  expect(written.some(p => p.endsWith('C:\\Users\\alex/.claude/ui-themes/active'))).toBe(true)
  expect(written.some(p => p.startsWith('/.claude'))).toBe(false)
})
