import { test, expect } from 'claude-code/testing'

const THEMES: Record<string, string> = {
  'claude-warm.json': JSON.stringify({ name: 'claude-warm', description: 'warm', prompt: { bg: '#000000' }, reply: { bg: '#000000' }, markdown: {} }),
  'night-blue.json': JSON.stringify({ name: 'night-blue', description: 'blue', prompt: { bg: '#000000' }, reply: { bg: '#000000' }, markdown: {} }),
}

test('picker pane lists the themes in a Select', async ($, on) => {
  on('env.get', () => ({ value: '/home/test' }) as any)
  on('fs.list', () => ({ value: Object.keys(THEMES).map(name => ({ name, kind: 'file' })) }) as any)
  on('fs.read', ($, e: any) => ({ value: THEMES[String(e.path).split('/').pop() ?? ''] ?? 'claude-warm' }) as any)
  const tree = await $.ui.render({
    surface: 'terminal', component: 'Pane', requestId: 'ui-theme-picker',
    props: { title: 'UI theme', isFocused: true, bodyColumns: 80, placement: 'inline' },
  } as any)
  const json = JSON.stringify(tree)
  expect(json).toContain('"type":"Select"')
  expect(json).toContain('claude-warm')
  expect(json).toContain('night-blue')
})
