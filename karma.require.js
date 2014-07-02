var tests = [];
for (var file in window.__karma__.files) {
    if (/_spec\.js$/.test(file)) {
        tests.push(file);
    }
}

require.config({
    baseUrl: '/base',
    paths: {
        appRegistry: 'components/common/util/appRegistry',
        appAuth: 'components/common/modules/auth',
        appI18n: 'components/common/modules/i18n',
        appTheme: 'components/common/modules/theme',
        appController: 'ciscoAdmin/WebContent/js/app/pages/apps/appController',
        homeController: 'ciscoAdmin/WebContent/js/app/pages/dashboard/homeController',
        profileController: 'ciscoAdmin/WebContent/js/app/pages/profile/profileController',
        stackatoService: 'ciscoAdmin/WebContent/js/app/common/services/stackatoService',
        restService: 'components/common/client/js/services/restService',
        'ui.grid': 'ng-grid',
        'ui.bootstrap': '../bower_components/ui.bootstrap/karma.conf',
        angular: '../bower_components/angular/angular',
        'angular-bootstrap': '../bower_components/angular-bootstrap/ui-bootstrap-tpls',
        'angular-mocks': '../bower_components/angular-mocks/angular-mocks',
        'angular-route': '../bower_components/angular-route/angular-route',
        'angular-ui-bootstrap-bower': '../bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls',
        bootstrap: '../bower_components/bootstrap/dist/js/bootstrap',
        jquery: '../bower_components/jquery/dist/jquery',
        'ng-grid': '../bower_components/ng-grid/build/ng-grid',
        'paralleljs-copy': '../bower_components/paralleljs-copy/lib/parallel',
        underscore: '../bower_components/underscore/underscore'
    },
    shim: {
        jquery: {
            exports: '$'
        },
        bootstrap: {
            deps: [
                'jquery'
            ]
        },
        angular: {
            deps: [
                'jquery'
            ],
            exports: 'angular'
        },
        'angular-route': {
            deps: [
                'angular'
            ]
        },
        'angular-mocks': {
            deps: [
                'angular'
            ]
        },
        'ui.grid': {
            deps: [
                'angular'
            ]
        },
        'ui.bootstrap': {
            deps: [
                'angular'
            ]
        }
    },
    callback: function (){if(window){window.__karma__.start()}},
    packages: [

    ]
});
