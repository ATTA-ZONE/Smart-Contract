import { adminTest } from './testsuite/setup.js'
import { useCase } from './testsuite/useCase.js'

describe('flowns test case', () => {
  adminTest()
  useCase()
})
