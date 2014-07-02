// var tests = [];
// for (var file in window.__karma__.files) {
//     if (/_test\.js$/.test(file)) {
//         tests.push(file);
//         console.log tests
//     }
// }
//

require.config({
  shim: {

  },
  paths: {
    angular: "../client/components/vendor/angular/angular",
    "angular-animate": "../client/components/vendor/angular-animate/angular-animate",
    "angular-bootstrap": "../client/components/vendor/angular-bootstrap/ui-bootstrap-tpls",
    "angular-dragdrop": "../client/components/vendor/angular-dragdrop/src/angular-dragdrop",
    jquery: "../client/components/vendor/jquery/dist/jquery",
    "jquery-ui": "../client/components/vendor/jquery-ui/ui/jquery-ui",
    "angular-resource": "../client/components/vendor/angular-resource/angular-resource",
    "angular-route": "../client/components/vendor/angular-route/angular-route",
    "angular-sanitize": "../client/components/vendor/angular-sanitize/angular-sanitize",
    "angular-touch": "../client/components/vendor/angular-touch/angular-touch",
    "angular-ui-bootstrap-bower": "../client/components/vendor/angular-ui-bootstrap-bower/ui-bootstrap-tpls",
    "angular-ui-select2": "../client/components/vendor/angular-ui-select2/src/select2",
    select2: "../client/components/vendor/select2/select2",
    "angular-xeditable": "../client/components/vendor/angular-xeditable/dist/js/xeditable",
    async2: "../client/components/vendor/async2/js/async",
    "bootstrap-multiselect": "../client/components/vendor/bootstrap-multiselect/js/bootstrap-multiselect",
    bootstrap: "../client/components/vendor/bootstrap/dist/js/bootstrap",
    fastclick: "../client/components/vendor/fastclick/lib/fastclick",
    highcharts: "../client/components/vendor/highcharts/highcharts",
    "jquery.gritter": "../client/components/vendor/jquery.gritter/js/jquery.gritter",
    momentjs: "../client/components/vendor/momentjs/moment",
    "ng-Fx": "../client/components/vendor/ng-Fx/dist/ng-Fx",
    gsap: "../client/components/vendor/gsap/src/uncompressed/TweenMax",
    "ng-grid": "../client/components/vendor/ng-grid/build/ng-grid",
    "paralleljs-copy": "../client/components/vendor/paralleljs-copy/lib/parallel",
    requirejs: "../client/components/vendor/requirejs/require",
    "requirejs-text": "../client/components/vendor/requirejs-text/text",
    skulpt: "../client/components/vendor/skulpt/skulpt",
    "skulpt-stdlib": "../client/components/vendor/skulpt/skulpt-stdlib",
    underscore: "../client/components/vendor/underscore/underscore"
  },
  packages: [

  ],
  baseUrl: "/base/compile"
});
