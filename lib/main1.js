
import _         from 'lodash';
import gulp      from 'gulp';
import commander from 'commander';
import Liftoff   from 'liftoff';
import chalk     from 'chalk';
import tildify   from 'tildify';
import fs        from 'fs';
import q         from 'q';

import {project} from './project.js';
import {args, log, notify, execute, merge} from './util.js';
import {user} from './user.js';

project.then((data)=> {
  console.log('Hello world!', data);
});
