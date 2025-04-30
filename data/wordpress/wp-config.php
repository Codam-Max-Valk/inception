<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wordpress' );

/** Database password */
define( 'DB_PASSWORD', 'wordpress_password' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'aBTSQfRC:R=gPl%N[WNScTK.awJ3%FQ&*Py~G0K1<wHV!0{P<vQM8)9`q0JRv-zd' );
define( 'SECURE_AUTH_KEY',   'E]D]7V3y~wwg7Y%J#&^B#xyaCU4pB.M)47DQOYHtVhcmizPiv{^De>9c92U0vD~u' );
define( 'LOGGED_IN_KEY',     'SdDSXV*=1G huQye7(V[nax3yF~AcY]Xy`?NH,vf2Ne K8jucjnOc)bgwkO^@W~-' );
define( 'NONCE_KEY',         'p5By/2Y[)!z6*_K ~i}T3o>{L?L=Y{>iRSZfJTCXnN_K-GpKM)9U6x)Fl#GGA`m?' );
define( 'AUTH_SALT',         'skCK4&|w^Ozl- )v%? nwdX91#ri3J}.nVcFA_kI^F,j$@3GY$4nc?5stxx#NSg_' );
define( 'SECURE_AUTH_SALT',  'PMTmHV?Mbdnq|T8te&tkb!}3S4~FXWDX5hIFU&:Kdfdd+|HTf}_dr$1>IQHA<M=H' );
define( 'LOGGED_IN_SALT',    'W3hfjX6Z2w:ZQOKz,9|.[0{h.v>4DCJ=P/ij#8wH;xX gsBoL-7Di@@5Uel_FH?^' );
define( 'NONCE_SALT',        'kH%hFvPs1QW+`<3g.a3-&#EAaGNP}r=K]ld|T( D(+piZkcQ<HDZt|JRXHKK^vpE' );
define( 'WP_CACHE_KEY_SALT', '[g @I+>MjrKvR^/dIp041{WAE4LP-`#o*0W/VG,.[<AeDRfU74w@vMvUB~)J!5GO' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
