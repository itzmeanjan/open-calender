const OpenCalender = artifacts.require('OpenCalender');

export default (deployer) => {
    deployer.deploy(OpenCalender);
};
