global.Plugin = require('../lib');
global.fs = require('fs');
global.sinon = require('sinon');

chai = require('chai');
chai.use(require('sinon-chai'));
chai.should();

global.expect = chai.expect;

