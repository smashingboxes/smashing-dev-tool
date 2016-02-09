import winston       from 'winston';
import notifier      from 'node-notifier';
import streamqueue   from 'streamqueue';
import {exec, spawn} from 'child_process';
import minimist      from 'minimist';
import _             from 'lodash';


// Normalize command-line arguments
export let args = minimist(process.argv.slice(2));


// Configure Winston logger instance
winston.cli()
export let log = new (winston.Logger)({
  transports: [new (winston.transports.Console)({
    colorize: true,
    level: args.verbose ? 'verbose' : 'info'
  })],
  levels:{
    silly: 0,
    verbose: 1,
    info: 2,
    data: 3,
    warn: 4,
    debug: 5,
    error: 6
  },
  colors:{
    silly: 'magenta',
    verbose: 'cyan',
    info: 'green',
    data: 'grey',
    warn: 'yellow',
    debug: 'blue',
    error: 'red'
  }
});

// Display a desktop notification (if available)
export function notify(title, message, type='info') {
  let msg = { title, message, group:type };
  notifier.notify(msg);
  logger.verbose(msg.message);
}

// Execute commands in the shell
export function execute(command, cb) {
  command = command.split(' ');
  cmd = spawn(command.shift(), command);

  cmd.stdout.on('data', (data) => {
    console.log(data.toString());
  });

  cmd.stderr.on('data', (data) => {
    console.error(data.toString());
  });

  cmd.on('exit', (code) => {
    logger.verbose(`execute(): child process exited with code ${code}`);
    cb();
  });
}

// Returns a new stream composed of all argument streams
export function merge(streams) {
  let queue = new streamqueue({objectMode:true});
  if (_.isArray(streams)) {
    streams.forEach(queue.queue);
    return queue.done();
  } else {
    log.error('merge(): no streams provided');
    return null;
  }
}
