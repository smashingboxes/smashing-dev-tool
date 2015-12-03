import Liftoff  from 'liftoff';
import chalk    from 'chalk';
import tildify  from 'tildify';
import _        from 'lodash';
import fs       from 'fs';
import q        from 'q';


import {args, log, notify, execute, merge} from './util.js';
let currentDir = process.cwd();
let defer = q.defer()


// Get base Smashfile config
let getDefaults = function() {
	log.verbose('Loading default Smashfile...')
	return require('./_smashfile').default;
}

// Parse Smashfile config for project
let getSmashfile = function(env) {
	log.verbose('Loading local Smashfile...')
	if (!env.configPath){
		log.warn('No SMASHFILE found');
		return {};
	} else {
		let style = chalk.magenta.underline;
		log.verbose('Working in directory', style(tildify(env.cwd)));
		log.verbose('Using Smashfile', style(tildify(env.configPath)));
		process.chdir(env.configBase);
		return require(env.configPath).default;

	}
}

// Gather information from project package.json/bower.json
let getPackageConfig = function() {
	log.verbose('Loading JSON manifest files...');
	return {
		pkg:{
			bower: (() => {
				if (fs.existsSync(`${currentDir}/bower.json`)){
					return require(`${currentDir}/bower`);
				} else {
					return null;
				}
			})(),

			npm: (()=>{
				if (fs.existsSync(`${currentDir}/package.json`)){
					return require(`${currentDir}/package.json`);
				} else {
					return null;
				}
			})()
		}
  }
}

// # Collect paths for easy reference
let getDirs = function (p){
	log.verbose('Building path aliases...');
	let dir = {
  	client:  p.client.path,
    server:  p.server.path,
    vendor:  p.vendor.path,
    compile: p.compile.path,
    build:   p.build.path,
    deploy:  p.deploy.path,
    docs:    p.docs.path,
    fonts:   p.fonts.path
	};
	return _.merge(p, { dir });
}

// Liftoff config data
let getEnv = function(env) {
	return { env };
}


// Configure Liftoff instance and load Smashfile
let devtool = new Liftoff({
	name:         'smash',
	processTitle: 'smasher',
	moduleName:   'smasher',
	configName:   'smashfile',
	extensions:   require('interpret').jsVariants
});

devtool.on('require', (name, _module) => {
	log.verbose(`Requiring external module ${chalk.magenta(name)}`);
})

devtool.launch({}, (env) => {
	defer.resolve(_({})
		.merge(getDefaults())
		.merge(getPackageConfig())
		.merge(getSmashfile(env))
		.thru(getDirs)
		.merge(getEnv(env))
		.value()
	);
});

export let project = defer.promise;
