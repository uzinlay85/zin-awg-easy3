'use strict';

const crypto = require('node:crypto');
const { release: { version } } = require('./package.json');

module.exports.RELEASE = version;
module.exports.PORT = process.env.PORT || '51833';
module.exports.WEBUI_HOST = process.env.WEBUI_HOST || '0.0.0.0';
module.exports.PASSWORD_HASH = process.env.PASSWORD_HASH;
module.exports.MAX_AGE = parseInt(process.env.MAX_AGE, 10) * 1000 * 60 || 0;
module.exports.WG_PATH = process.env.WG_PATH || '/etc/wireguard/';
module.exports.WG_DEVICE = process.env.WG_DEVICE || 'eth0';
module.exports.WG_HOST = process.env.WG_HOST;
module.exports.WG_PORT = process.env.WG_PORT || '51820';
module.exports.WG_CONFIG_PORT = process.env.WG_CONFIG_PORT || process.env.WG_PORT || '51820';
module.exports.WG_MTU = process.env.WG_MTU || '1280';
module.exports.WG_PERSISTENT_KEEPALIVE = process.env.WG_PERSISTENT_KEEPALIVE || '25';
module.exports.WG_DEFAULT_ADDRESS = process.env.WG_DEFAULT_ADDRESS || '10.8.1.x';
module.exports.WG_DEFAULT_DNS = typeof process.env.WG_DEFAULT_DNS === 'string'
  ? process.env.WG_DEFAULT_DNS
  : '1.1.1.1, 1.0.0.1';
module.exports.WG_ALLOWED_IPS = process.env.WG_ALLOWED_IPS || '0.0.0.0/0, ::/0';

module.exports.WG_PRE_UP = process.env.WG_PRE_UP || '';
module.exports.WG_POST_UP = process.env.WG_POST_UP || `
iptables -t nat -A POSTROUTING -s ${module.exports.WG_DEFAULT_ADDRESS.replace('x', '0')}/24 -o ${module.exports.WG_DEVICE} -j MASQUERADE;
iptables -A INPUT -p udp -m udp --dport ${module.exports.WG_PORT} -j ACCEPT;
iptables -A FORWARD -i wg0 -j ACCEPT;
iptables -A FORWARD -o wg0 -j ACCEPT;
`.split('\n').join(' ');

module.exports.WG_PRE_DOWN = process.env.WG_PRE_DOWN || '';
module.exports.WG_POST_DOWN = process.env.WG_POST_DOWN || `
iptables -t nat -D POSTROUTING -s ${module.exports.WG_DEFAULT_ADDRESS.replace('x', '0')}/24 -o ${module.exports.WG_DEVICE} -j MASQUERADE;
iptables -D INPUT -p udp -m udp --dport ${module.exports.WG_PORT} -j ACCEPT;
iptables -D FORWARD -i wg0 -j ACCEPT;
iptables -D FORWARD -o wg0 -j ACCEPT;
`.split('\n').join(' ');
module.exports.LANG = process.env.LANG || 'en';
module.exports.UI_TRAFFIC_STATS = process.env.UI_TRAFFIC_STATS || 'false';
module.exports.UI_CHART_TYPE = process.env.UI_CHART_TYPE || 0;
module.exports.WG_ENABLE_ONE_TIME_LINKS = process.env.WG_ENABLE_ONE_TIME_LINKS || 'false';
module.exports.UI_ENABLE_SORT_CLIENTS = process.env.UI_ENABLE_SORT_CLIENTS || 'false';
module.exports.WG_ENABLE_EXPIRES_TIME = process.env.WG_ENABLE_EXPIRES_TIME || 'false';
module.exports.ENABLE_PROMETHEUS_METRICS = process.env.ENABLE_PROMETHEUS_METRICS || 'false';
module.exports.PROMETHEUS_METRICS_PASSWORD = process.env.PROMETHEUS_METRICS_PASSWORD;

module.exports.DICEBEAR_TYPE = process.env.DICEBEAR_TYPE || false;
module.exports.USE_GRAVATAR = process.env.USE_GRAVATAR || false;

const getRandomInt = (min, max) => min + Math.floor(Math.random() * (max - min));
// AWG 3.1 HeaderProtectionKey requires junk sizes S1..S4 to be at least 12
const getRandomJunkSize = () => getRandomInt(15, 60);

const makeHeaderRanges = (totalMin = 1000000000, totalMax = 4294967295) => {
  const zoneSize = Math.floor((totalMax - totalMin) / 4);
  const result = [];
  for (let i = 0; i < 4; i++) {
    const zStart = totalMin + i * zoneSize;
    const zEnd = zStart + zoneSize - 1;
    const padding = Math.min(100000, Math.floor(zoneSize / 4));
    const a = getRandomInt(zStart + padding, zEnd - padding);
    const b = getRandomInt(a + 1, zEnd);
    result.push(`${a}-${b}`);
  }
  return result;
};

const defaultHeaderRanges = makeHeaderRanges();

module.exports.JC = process.env.JC || getRandomInt(3, 10);
module.exports.JMIN = process.env.JMIN || 15;
module.exports.JMAX = process.env.JMAX || 52;
module.exports.S1 = process.env.S1 || getRandomJunkSize();
module.exports.S2 = process.env.S2 || getRandomJunkSize();
module.exports.S3 = process.env.S3 || getRandomJunkSize();
module.exports.S4 = process.env.S4 || getRandomJunkSize();
module.exports.H1 = process.env.H1 || defaultHeaderRanges[0];
module.exports.H2 = process.env.H2 || defaultHeaderRanges[1];
module.exports.H3 = process.env.H3 || defaultHeaderRanges[2];
module.exports.H4 = process.env.H4 || defaultHeaderRanges[3];

// Special junk packets (optional, empty by default to prevent client handshake failure)
module.exports.I1 = process.env.I1 || '';
module.exports.I2 = process.env.I2 || '';
module.exports.I3 = process.env.I3 || '';
module.exports.I4 = process.env.I4 || '';
module.exports.I5 = process.env.I5 || '';

// AWG 3.1 parameters
const getRandomPaddingRange = () => {
  const min = getRandomInt(8, 20);
  return `${min}-${min + getRandomInt(24, 48)}`;
};

const rekeyAfterStart = getRandomInt(100, 130);
const defaultRekeyAfterTime = `${rekeyAfterStart}-${rekeyAfterStart + getRandomInt(10, 30)}`;
const defaultRekeyTimeout = `${getRandomInt(4, 6)}-${getRandomInt(6, 8)}`;
const rejectAfterStart = getRandomInt(rekeyAfterStart + 40, rekeyAfterStart + 70);
const defaultRejectAfterTime = `${rejectAfterStart}-${rejectAfterStart + getRandomInt(10, 30)}`;
const defaultKeepaliveTimeout = `${getRandomInt(8, 12)}-${getRandomInt(13, 16)}`;
const defaultHandshakeAttempts = `${getRandomInt(15, 20)}-${getRandomInt(20, 25)}`;

module.exports.HEADER_PROTECTION_KEY = process.env.HEADER_PROTECTION_KEY || crypto.randomBytes(32).toString('base64');
module.exports.CONTENT_PADDING_ADDITION = process.env.CONTENT_PADDING_ADDITION || getRandomPaddingRange();
module.exports.REKEY_AFTER_TIME = process.env.REKEY_AFTER_TIME || defaultRekeyAfterTime;
module.exports.REKEY_TIMEOUT = process.env.REKEY_TIMEOUT || defaultRekeyTimeout;
module.exports.REJECT_AFTER_TIME = process.env.REJECT_AFTER_TIME || defaultRejectAfterTime;
module.exports.KEEPALIVE_TIMEOUT = process.env.KEEPALIVE_TIMEOUT || defaultKeepaliveTimeout;
module.exports.MAX_HANDSHAKE_ATTEMPTS = process.env.MAX_HANDSHAKE_ATTEMPTS || defaultHandshakeAttempts;
module.exports.RANDOM_TRAILERS = process.env.RANDOM_TRAILERS || 'on';
module.exports.DISABLE_COOKIES = process.env.DISABLE_COOKIES || 'on';



