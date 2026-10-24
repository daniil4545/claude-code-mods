import { test, expect } from 'claude-code/testing'

// #2: the status line script is installed once and only replaced on request.
const ROOT_SCRIPT = '#!/usr/bin/env bash\necho v1\n'

function fakeFs(files: Record<string, string>, on: any, shipped: string) {
  const plugin = (p: string) => p.includes('/statusline/statusline.sh') ? shipped
    : p.endsWith('/.claude-plugin/plugin.json') ? '{"version":"9.9.9"}' : undefined
  on('env.get', () => ({ value: '/home/t' }))
  on('fs.exists', ($: any, e: any) => ({ value: e.path in files || plugin(e.path) !== undefined }))
  on('fs.read', ($: any, e: any) => {
    const v = files[e.path] ?? plugin(e.path)
    return v === undefined ? { deny: 'ENOENT' } : { value: v }
  })
  on('fs.write', ($: any, e: any) => { files[e.path] = e.text; return { value: undefined } })
  on('fs.list', ($: any, e: any) => ({ value: String(e.path).endsWith('/themes') ? [] : [] }))
  on('command.register', () => ({ value: undefined }))
  on('session.start', () => ({ cwd: '/tmp' }) as any)
  on('ui.invalidate', () => ({ value: undefined }))
}

const S = '/home/t/.claude/ui-themes/statusline.sh'

test('fresh install copies the script and records it', async ($, on) => {
  const files: Record<string, string> = {}
  const toasts: string[] = []
  fakeFs(files, on, ROOT_SCRIPT)
  on('ui.toast', ($: any, e: any) => { toasts.push(String(e.text ?? e.message ?? '')); return { value: undefined } })
  await $.session.start({ source: 'startup', cwd: '/tmp' } as any)
  expect(files[S]).toBe(ROOT_SCRIPT)
  expect(toasts.length).toBe(0)
})

test('a new shipped script is NOT copied over; the person is told; update applies it with a backup', async ($, on) => {
  const files: Record<string, string> = { [S]: ROOT_SCRIPT, '/home/t/.claude/ui-themes/active': 'claude-warm\n' }
  const toasts: string[] = []
  fakeFs(files, on, '#!/usr/bin/env bash\necho v2\n')
  on('ui.toast', ($: any, e: any) => { toasts.push(JSON.stringify(e)); return { value: undefined } })
  await $.session.start({ source: 'startup', cwd: '/tmp' } as any)
  expect(files[S]).toBe(ROOT_SCRIPT)
  expect(toasts.join(' ')).toContain('statusline update')
  const out: any = await $.command.run({ command: 'ui-theme', args: 'statusline update' } as any)
  expect(files[S]).toContain('echo v2')
  expect(files[S + '.bak']).toBe(ROOT_SCRIPT)
  expect(JSON.stringify(out)).toContain('1 line(s) added, 1 removed')
})

test("the person's own edits are kept and not nagged about", async ($, on) => {
  const files: Record<string, string> = { [S]: ROOT_SCRIPT }
  const toasts: string[] = []
  fakeFs(files, on, ROOT_SCRIPT)
  on('ui.toast', ($: any, e: any) => { toasts.push(JSON.stringify(e)); return { value: undefined } })
  await $.session.start({ source: 'startup', cwd: '/tmp' } as any) // records the marker
  files[S] = ROOT_SCRIPT + 'echo my edit\n'
  await $.session.start({ source: 'startup', cwd: '/tmp' } as any)
  expect(files[S]).toContain('my edit')
  expect(toasts.length).toBe(0)
})
