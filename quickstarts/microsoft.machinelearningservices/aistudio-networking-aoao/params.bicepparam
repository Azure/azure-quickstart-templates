using './main.bicep'

param prefix = 'GEN-UNIQUE-4'
param suffix = 'GEN-UNIQUE-4'
param userObjectId = ''
param vmAdminUsername = 'azadmin'
param vmAdminPasswordOrKey = 'GEN-PASSWORD'
param openAiDeployments = [
  {
    model: {
      name: 'text-embedding-ada-002'
      version: '2'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
  }
  {
    model: {
      name: 'gpt-4o'
      version: '2024-05-13'
    }
    sku: {
      name: 'GlobalStandard'
      capacity: 10
    }
  }
]
param tags = {
  environment: 'development'
  iac: 'bicep'
}
