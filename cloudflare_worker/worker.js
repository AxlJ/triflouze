/**
 * Cloudflare Worker — Triflouze notification proxy
 *
 * Stocke la clé REST OneSignal côté serveur (secret Cloudflare).
 * Flutter envoie les payloads ici, le Worker les forward à OneSignal.
 *
 * Déploiement :
 *   1. Installer Wrangler : npm install -g wrangler
 *   2. wrangler login
 *   3. Depuis ce dossier : wrangler deploy
 *   4. Ajouter les secrets :
 *        wrangler secret put ONESIGNAL_APP_ID
 *        wrangler secret put ONESIGNAL_REST_KEY
 *   5. Copier l'URL affichée (ex: https://triflouze-notify.xxx.workers.dev)
 *      et la coller dans lib/services/notification_service.dart (_workerUrl)
 */

export default {
  async fetch(request, env) {
    // CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    let body;
    try {
      body = await request.json();
    } catch (_) {
      return new Response('Bad Request', { status: 400 });
    }

    const { targets, headings, contents } = body;

    if (!Array.isArray(targets) || targets.length === 0) {
      return new Response(JSON.stringify({ skipped: true }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const oneSignalRes = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${env.ONESIGNAL_REST_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        app_id: env.ONESIGNAL_APP_ID,
        include_aliases: { external_id: targets },
        target_channel: 'push',
        headings,
        contents,
      }),
    });

    const responseText = await oneSignalRes.text();
    return new Response(responseText, {
      status: oneSignalRes.status,
      headers: { 'Content-Type': 'application/json' },
    });
  },
};
