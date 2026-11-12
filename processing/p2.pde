
float x1, y1, x2, y2;

float vx1 = 24, vy1 = 19.5;
float vx2 = -21, vy2 = -18;

// Las dos bolas tienen el mismo tamaño
float r1 = 85;
float r2 = 85;

float gravedad = 0.12;
float rebote = 1.0;
float velocidadMaxima = 38;

float tono1 = 210;
float tono2 = 0;

float velocidadColor1 = 0.8;
float velocidadColor2 = 1.0;

color color1;
color color2;

PGraphics pintura;

// EXPORTACIÓN
int totalFotogramas = 250;
int fotograma = 0;

void setup() {

  size(540, 960);

  smooth(8);
  frameRate(25);

  colorMode(HSB, 360, 100, 100);

  new java.io.File(sketchPath("frames")).mkdirs();

  pintura = createGraphics(1080, 1920);
  pintura.smooth(8);

  pintura.beginDraw();
  pintura.colorMode(RGB, 255);
  pintura.background(255, 255, 255);
  pintura.endDraw();

  x1 = 1080 * 0.30;
  y1 = 1920 * 0.30;

  x2 = 1080 * 0.70;
  y2 = 1920 * 0.65;

  color1 = color(tono1, 100, 100);
  color2 = color(tono2, 100, 100);
}

void draw() {

  // Cambio continuo de colores
  tono1 = (tono1 + velocidadColor1) % 360;
  tono2 = (tono2 + velocidadColor2) % 360;

  color1 = color(tono1, 100, 100);
  color2 = color(tono2, 100, 100);

  // Gravedad
  vy1 += gravedad;
  vy2 += gravedad;

  // Limitar velocidad
  vx1 = constrain(vx1, -velocidadMaxima, velocidadMaxima);
  vy1 = constrain(vy1, -velocidadMaxima, velocidadMaxima);
  vx2 = constrain(vx2, -velocidadMaxima, velocidadMaxima);
  vy2 = constrain(vy2, -velocidadMaxima, velocidadMaxima);

  // Movimiento
  x1 += vx1;
  y1 += vy1;
  x2 += vx2;
  y2 += vy2;

  // Rebotes del primer círculo
  if (x1 - r1 < 0) {
    x1 = r1;
    vx1 = abs(vx1) * rebote;
  }

  if (x1 + r1 > 1080) {
    x1 = 1080 - r1;
    vx1 = -abs(vx1) * rebote;
  }

  if (y1 - r1 < 0) {
    y1 = r1;
    vy1 = abs(vy1) * rebote;
  }

  if (y1 + r1 > 1920) {
    y1 = 1920 - r1;
    vy1 = -abs(vy1) * rebote;
  }

  // Rebotes del segundo círculo
  if (x2 - r2 < 0) {
    x2 = r2;
    vx2 = abs(vx2) * rebote;
  }

  if (x2 + r2 > 1080) {
    x2 = 1080 - r2;
    vx2 = -abs(vx2) * rebote;
  }

  if (y2 - r2 < 0) {
    y2 = r2;
    vy2 = abs(vy2) * rebote;
  }

  if (y2 + r2 > 1920) {
    y2 = 1920 - r2;
    vy2 = -abs(vy2) * rebote;
  }

  // Colisión entre círculos
  float dx = x2 - x1;
  float dy = y2 - y1;

  float distancia = sqrt(dx * dx + dy * dy);
  float distanciaMinima = r1 + r2;

  if (distancia < distanciaMinima && distancia > 0) {

    float nx = dx / distancia;
    float ny = dy / distancia;

    float solapamiento = distanciaMinima - distancia;

    x1 -= nx * solapamiento / 2;
    y1 -= ny * solapamiento / 2;

    x2 += nx * solapamiento / 2;
    y2 += ny * solapamiento / 2;

    float relativaX = vx2 - vx1;
    float relativaY = vy2 - vy1;

    float velocidadNormal =
      relativaX * nx + relativaY * ny;

    if (velocidadNormal < 0) {

      float impulso =
        -(1 + rebote) * velocidadNormal / 2;

      vx1 -= impulso * nx;
      vy1 -= impulso * ny;

      vx2 += impulso * nx;
      vy2 += impulso * ny;
    }
  }

  // Pintar círculos y conservar rastros
  pintura.beginDraw();

  pintura.colorMode(HSB, 360, 100, 100);
  pintura.noStroke();

  pintura.fill(color1);
  pintura.ellipse(x1, y1, r1 * 2, r1 * 2);

  pintura.fill(color2);
  pintura.ellipse(x2, y2, r2 * 2, r2 * 2);

  pintura.endDraw();

  // Fondo blanco puro
  colorMode(RGB, 255);
  background(255, 255, 255);

  // Ventana reducida al 50%
  image(pintura, 0, 0, 540, 960);

  // EXPORTAR PNG
  if (fotograma < totalFotogramas) {

    String nombre = "frames/frame-" + nf(fotograma, 4) + ".png";

    pintura.save(sketchPath(nombre));

    fotograma++;

    println("Fotograma: " + fotograma + " / " + totalFotogramas);

    if (fotograma >= totalFotogramas) {

      println("¡EXPORTACIÓN TERMINADA!");
      println("250 imágenes PNG guardadas en la carpeta frames.");

      noLoop();
    }
  }

  colorMode(HSB, 360, 100, 100);
}
