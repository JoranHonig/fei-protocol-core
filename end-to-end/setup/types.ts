const { web3 } = require('hardhat');
const { Contract } = web3.eth

export type TestEnv = {
  contracts: TestEnvContracts,
  contractAddresses: TestEnvContractAddresses
}

export interface TestCoordinator {
  initialiseLocalEnv(): Promise<TestEnv>;
  initialiseMainnetEnv(): Promise<TestEnv>;
}

export type Config = {
  version: number;
  deployAddress: string;
  logging: boolean;
}

export type ExistingProtocolContracts = {
  core: typeof Contract,
  tribe: typeof Contract,
  fei: typeof Contract,
  ethReserveStabilizer: typeof Contract,
}

export type TestEnvContracts = {
  core: typeof Contract,
  tribe: typeof Contract,
  fei: typeof Contract,
  uniswapPCVDeposit: typeof Contract,
  uniswapPCVController: typeof Contract,
  bondingCurve: typeof Contract,
  chainlinkEthUsdOracleWrapper: typeof Contract,
  chainlinkFeiEthOracleWrapper: typeof Contract,
  compositeOracle: typeof Contract,
  ethReserveStabilizer: typeof Contract,
  pcvDripController: typeof Contract,
  ratioPCVController: typeof Contract,
  tribeReserveStabilizer: typeof Contract,
}

export type TestEnvContractAddresses = {
  core: string,
  tribe: string,
  fei: string,
  uniswapPCVDeposit: string,
  uniswapPCVController: string,
  bondingCurve: string,
  chainlinkEthUsdOracleWrapper: string,
  chainlinkFeiEthOracleWrapper: string,
  compositeOracle: string,
  ethReserveStabilizer: string,
  pcvDripController: string,
  ratioPCVController: string,
  tribeReserveStabilizer: string,
}

export type MainnetContractAddresses = {
  core: string,
  tribe: string,
  fei: string,
  uniswapPCVDeposit: string,
  uniswapPCVController: string,
  bondingCurve: string,
  chainlinkEthUsdOracleWrapper: string,
  chainlinkFeiEthOracleWrapper: string,
  compositeOracle: string
  ethReserveStabilizer: string,
  pcvDripController: string,
  ratioPCVController: string,
  tribeReserveStabilizer: string,
  weth: string,
  uniswapRouter: string,
  feiEthPair: string,
  uniswapOracle: string,
}

export type LocalContractAddresses = {
  core: string,
  tribe: string,
  fei: string,
  uniswapPCVDeposit: string,
  uniswapPCVController: string,
  bondingCurve: string,
  chainlinkEthUsdOracleWrapper: string,
  chainlinkFeiEthOracleWrapper: string,
  compositeOracle: string
  ethReserveStabilizer: string,
  pcvDripController: string,
  ratioPCVController: string,
  tribeReserveStabilizer: string,
  weth: string,
  uniswapRouter: string,
  feiEthPair: string,
  uniswapOracle: string,
}

export type ContractAccessRights = 
  {
    minter: string[],
    burner: string[],
    governor: string[],
    pcvController: string[],
    guardian: string[],
  }