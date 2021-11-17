import { adminTest } from './testsuite/setup.js'
import { useCase } from './testsuite/useCase.js'

describe('contract test case', () => {
  adminTest()
  useCase()
})
