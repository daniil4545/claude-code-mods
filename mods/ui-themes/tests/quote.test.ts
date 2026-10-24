import { test, expect } from 'claude-code/testing'

test('a multi-line quote keeps its list instead of one flattened line', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, () => null as any)
  const tree = await $.ui.render({
    surface: 'terminal', component: 'AssistantMessage', requestId: 'm2',
    props: { text: '> **Open items**\n>\n> 1. first\n> 2. second', isFirstOfReply: true },
  } as any)
  const json = JSON.stringify(tree)
  expect(json).toContain('"round"')
  // list markers are their own elements, not part of one joined string
  expect(json).toContain('"1."')
  expect(json).toContain('"2."')
})

test('plain multi-line prose keeps the │ bar instead of a frame', async ($, on) => {
  on('ui.render', { component: 'AssistantMessage' }, () => null as any)
  const tree = await $.ui.render({
    surface: 'terminal', component: 'AssistantMessage', requestId: 'm3',
    props: { text: '> This is a longer note that was written\n> across two lines of plain prose.', isFirstOfReply: true },
  } as any)
  const json = JSON.stringify(tree)
  expect(json).toContain('│ ')
  expect(json).not.toContain('"round"')
  expect(json).toContain('written across')
})
