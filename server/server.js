const http = require('node:http');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const port = Number(process.env.PORT || 8080);
const secret = process.env.JWT_SECRET || 'local-development-secret-change-me';
const dataFile = process.env.DATA_FILE || path.join(__dirname, 'data.json');
const categories = ['Enfoque', 'Memoria', 'Lectura', 'Planificación'];
const names = [
  'Pomodoro 25/5', 'Recuperación activa', 'Repetición espaciada', 'Mapa conceptual',
  'Método Feynman', 'Lectura SQ3R', 'Bloques de tiempo', 'Intercalado de materias',
  'Tarjetas de memoria', 'Preguntas de práctica', 'Resumen de una página', 'Doble codificación',
  'Objetivos SMART', 'Matriz de prioridades', 'Repaso acumulativo', 'Diario de aprendizaje',
  'Estudio sin distracciones', 'Explicación en voz alta', 'Simulacro cronometrado', 'Revisión semanal'
];
const resources = names.map((title, index) => ({
  id: String(index + 1), title, category: categories[index % categories.length],
  description: `Técnica práctica para mejorar ${categories[index % categories.length].toLowerCase()} durante tus sesiones.`,
  minutes: 10 + (index % 6) * 5,
}));

function loadDb() {
  try { return JSON.parse(fs.readFileSync(dataFile, 'utf8')); }
  catch { return { users: [], tasks: [] }; }
}
function saveDb(db) { fs.writeFileSync(dataFile, JSON.stringify(db, null, 2)); }
function encode(value) { return Buffer.from(JSON.stringify(value)).toString('base64url'); }
function sign(userId) {
  const payload = encode({ sub: userId, exp: Date.now() + 7 * 86400000 });
  const signature = crypto.createHmac('sha256', secret).update(payload).digest('base64url');
  return `${payload}.${signature}`;
}
function verify(request) {
  const token = (request.headers.authorization || '').replace(/^Bearer /, '');
  const [payload, signature] = token.split('.');
  if (!payload || !signature) return null;
  const expected = crypto.createHmac('sha256', secret).update(payload).digest('base64url');
  if (signature.length !== expected.length || !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
  const decoded = JSON.parse(Buffer.from(payload, 'base64url').toString());
  return decoded.exp > Date.now() ? decoded.sub : null;
}
function passwordHash(password, salt = crypto.randomBytes(16).toString('hex')) {
  return { salt, hash: crypto.scryptSync(password, salt, 64).toString('hex') };
}
function response(res, status, body) {
  res.writeHead(status, {'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*'});
  res.end(JSON.stringify(body));
}
async function bodyOf(req) {
  let raw = ''; for await (const chunk of req) { raw += chunk; if (raw.length > 100000) throw new Error('too-large'); }
  return raw ? JSON.parse(raw) : {};
}

async function handler(req, res) {
  if (req.method === 'OPTIONS') { res.writeHead(204, {'access-control-allow-origin': '*', 'access-control-allow-headers': 'authorization,content-type', 'access-control-allow-methods': 'GET,POST,PUT,DELETE'}); return res.end(); }
  const url = new URL(req.url, `http://${req.headers.host}`); const db = loadDb();
  try {
    if (req.method === 'GET' && url.pathname === '/health') return response(res, 200, {status: 'ok'});
    if (req.method === 'GET' && url.pathname === '/resources') return response(res, 200, {items: resources});
    if (req.method === 'POST' && ['/auth/register', '/auth/login'].includes(url.pathname)) {
      const {email = '', password = ''} = await bodyOf(req);
      if (!email.includes('@') || password.length < 8) return response(res, 422, {message: 'Correo inválido o contraseña menor a 8 caracteres.'});
      let user = db.users.find((item) => item.email === email.toLowerCase());
      if (url.pathname.endsWith('register')) {
        if (user) return response(res, 400, {message: 'Ese correo ya está registrado.'});
        const passwordData = passwordHash(password);
        user = {id: crypto.randomUUID(), email: email.toLowerCase(), ...passwordData}; db.users.push(user); saveDb(db);
      } else {
        if (!user || passwordHash(password, user.salt).hash !== user.hash) return response(res, 401, {message: 'Credenciales incorrectas.'});
      }
      return response(res, 200, {token: sign(user.id)});
    }
    const userId = verify(req); if (!userId) return response(res, 401, {message: 'Debes iniciar sesión.'});
    if (url.pathname === '/tasks' && req.method === 'GET') return response(res, 200, {items: db.tasks.filter((item) => item.userId === userId)});
    if (url.pathname === '/tasks' && req.method === 'POST') {
      const input = await bodyOf(req); if (!input.title || !input.subject) return response(res, 422, {message: 'Título y materia son obligatorios.'});
      const item = {id: crypto.randomUUID(), userId, ...input}; db.tasks.push(item); saveDb(db); return response(res, 201, {item});
    }
    const taskMatch = url.pathname.match(/^\/tasks\/([^/]+)$/);
    if (taskMatch) {
      const index = db.tasks.findIndex((item) => item.id === taskMatch[1] && item.userId === userId);
      if (index < 0) return response(res, 404, {message: 'Actividad no encontrada.'});
      if (req.method === 'DELETE') { db.tasks.splice(index, 1); saveDb(db); return response(res, 200, {deleted: true}); }
      if (req.method === 'PUT') { db.tasks[index] = {...db.tasks[index], ...(await bodyOf(req)), id: taskMatch[1], userId}; saveDb(db); return response(res, 200, {item: db.tasks[index]}); }
    }
    if (url.pathname === '/ai/plan' && req.method === 'POST') {
      const {prompt = ''} = await bodyOf(req); if (prompt.trim().length < 10) return response(res, 422, {message: 'Describe mejor tus necesidades de estudio.'});
      if (!process.env.OPENAI_API_KEY) return response(res, 503, {message: 'El asistente no está configurado en el servidor.'});
      const ai = await fetch('https://api.openai.com/v1/responses', {method: 'POST', headers: {'content-type': 'application/json', authorization: `Bearer ${process.env.OPENAI_API_KEY}`}, body: JSON.stringify({model: process.env.OPENAI_MODEL || 'gpt-4.1-mini', instructions: 'Eres un planificador académico. Responde en español con un plan breve, seguro, realista y accionable.', input: prompt})});
      if (!ai.ok) return response(res, 502, {message: 'El proveedor de IA no respondió correctamente.'});
      const result = await ai.json(); return response(res, 200, {answer: result.output_text || 'No fue posible generar el plan.'});
    }
    return response(res, 404, {message: 'Ruta no encontrada.'});
  } catch (error) { console.error(error); return response(res, 500, {message: 'Error interno del servidor.'}); }
}

if (require.main === module) http.createServer(handler).listen(port, '0.0.0.0', () => console.log(`StudyFlow API en http://0.0.0.0:${port}`));
module.exports = {handler, resources};
