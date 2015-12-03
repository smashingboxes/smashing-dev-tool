
let gitConfig = require('git-config').sync()

export let user = gitConfig.user || {};
user.git = gitConfig;
user.homeDir =  process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
user.username = gitConfig.github ? gitConfig.github.user : user.homeDir.split("/").pop() || 'root'
