<?php

$databases = [];
$databases['default']['default'] = [
    'driver' => 'mysql',
    #'namespace' => 'Drupal\my_module\Driver\Database\my_driver',
    #'autoload' => 'modules/my_module/src/Driver/Database/my_driver/',
    'database' => 'drupal',
    'username' => 'drupal',
    'password' => 'drupal',
    'host' => '10.255.0.14',
    'prefix' => 'dru_',
    'port' => '3306',
];

$settings['hash_salt'] = include (__DIR__ . '/hash_salt.php');
$settings['update_free_access'] = FALSE;
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';
$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$settings['migrate_node_migrate_type_classic'] = FALSE;

