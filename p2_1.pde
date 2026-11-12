
import java.util.ArrayList;

ArrayList<Punto> puntos = new ArrayList<Punto>();
ArrayList<Punto> nuevos = new ArrayList<Punto>();

int anchoLienzo = 1080;
int altoLienzo = 1920;
float escala = 0.5;

float grosor = 22;
float gravedad = 0.10;
float rebote = 1.0;

// VELOCIDAD AUMENTADA
float velocidadMaxima = 48;

int maxPuntos = 250;
int esperaChoque = 12;

PGraphics pintura;

// EXPORTACIÓN
int totalFotogramas = 250;
int fotograma = 0;

void setup() {

  size(540, 960);
  smooth(8);
  frameRate(25);

  colorMode(HSB, 360, 100, 100);

  // Crear carpeta de exportación
  new java.io.File(sketchPath("frames")).mkdirs();

  for (int i = 0; i < 6; i++) {
    crearPunto();
  }

  pintura = createGraphics(anchoLienzo, altoLienzo);
  pintura.smooth(8);

  pintura.beginDraw();
  pintura.colorMode(HSB, 360, 100, 100);
  pintura.background(0, 0, 100);
  pintura.endDraw();
}

void draw() {

  for (Punto p : puntos) {

    p.px = p.x;
    p.py = p.y;

    p.tono = (p.tono + p.velColor) % 360;
    p.col = color(p.tono, 100, 100);

    p.vy += gravedad;

    p.vx = constrain(p.vx, -velocidadMaxima, velocidadMaxima);
    p.vy = constrain(p.vy, -velocidadMaxima, velocidadMaxima);

    p.x += p.vx;
    p.y += p.vy;

    if (!p.dentro) {
      if (p.x >= grosor / 2 &&
          p.x <= anchoLienzo - grosor / 2 &&
          p.y >= grosor / 2 &&
          p.y <= altoLienzo - grosor / 2) {
        p.dentro = true;
      }
    }

    if (p.dentro) {

      if (p.x < grosor / 2) {
        p.x = grosor / 2;
        p.vx = abs(p.vx) * rebote;
      }

      if (p.x > anchoLienzo - grosor / 2) {
        p.x = anchoLienzo - grosor / 2;
        p.vx = -abs(p.vx) * rebote;
      }

      if (p.y < grosor / 2) {
        p.y = grosor / 2;
        p.vy = abs(p.vy) * rebote;
      }

      if (p.y > altoLienzo - grosor / 2) {
        p.y = altoLienzo - grosor / 2;
        p.vy = -abs(p.vy) * rebote;
      }
    }
  }

  int cantidad = puntos.size();

  for (int i = 0; i < cantidad; i++) {
    for (int j = i + 1; j < cantidad; j++) {

      Punto a = puntos.get(i);
      Punto b = puntos.get(j);

      if (!a.dentro || !b.dentro) continue;

      float dx = b.x - a.x;
      float dy = b.y - a.y;

      float distancia = sqrt(dx * dx + dy * dy);
      float distanciaMinima = grosor * 2;

      if (distancia < distanciaMinima && distancia > 0) {

        float nx = dx / distancia;
        float ny = dy / distancia;

        float solapamiento = distanciaMinima - distancia;

        a.x -= nx * solapamiento / 2;
        a.y -= ny * solapamiento / 2;

        b.x += nx * solapamiento / 2;
        b.y += ny * solapamiento / 2;

        float relativaX = b.vx - a.vx;
        float relativaY = b.vy - a.vy;

        float velocidadNormal =
          relativaX * nx + relativaY * ny;

        if (velocidadNormal < 0) {

          float impulso =
            -(1 + rebote) * velocidadNormal / 2;

          a.vx -= impulso * nx;
          a.vy -= impulso * ny;

          b.vx += impulso * nx;
          b.vy += impulso * ny;

          if (frameCount - a.ultimoChoque > esperaChoque &&
              frameCount - b.ultimoChoque > esperaChoque &&
              puntos.size() + nuevos.size() < maxPuntos) {

            float nuevoX = (a.x + b.x) / 2;
            float nuevoY = (a.y + b.y) / 2;

            // Nuevos puntos más rápidos
            Punto nuevo = new Punto(
              nuevoX,
              nuevoY,
              random(-33, 33),
              random(-33, 33),
              random(360)
            );

            nuevo.dentro = true;
            nuevos.add(nuevo);

            a.ultimoChoque = frameCount;
            b.ultimoChoque = frameCount;
          }
        }
      }
    }
  }

  puntos.addAll(nuevos);
  nuevos.clear();

  // Pintar y conservar rastros
  pintura.beginDraw();
  pintura.strokeWeight(grosor);
  pintura.strokeCap(ROUND);

  for (Punto p : puntos) {
    pintura.stroke(p.col);
    pintura.line(p.px, p.py, p.x, p.y);
  }

  pintura.endDraw();

  // Fondo blanco
  colorMode(RGB, 255);
  background(255, 255, 255);

  // Mostrar lienzo al 50%
  image(pintura, 0, 0, 540, 960);

  colorMode(HSB, 360, 100, 100);
  noStroke();

  for (Punto p : puntos) {
    fill(p.col);
    ellipse(
      p.x * escala,
      p.y * escala,
      grosor * escala,
      grosor * escala
    );
  }

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
}

// CREAR PUNTOS
void crearPunto() {

  float px, py, vpx, vpy;

  int lado = int(random(4));

  if (lado == 0) {
    px = -30;
    py = random(altoLienzo);
    vpx = random(18, 30);
    vpy = random(-21, 21);

  } else if (lado == 1) {
    px = anchoLienzo + 30;
    py = random(altoLienzo);
    vpx = random(-30, -18);
    vpy = random(-21, 21);

  } else if (lado == 2) {
    px = random(anchoLienzo);
    py = -30;
    vpx = random(-21, 21);
    vpy = random(18, 30);

  } else {
    px = random(anchoLienzo);
    py = altoLienzo + 30;
    vpx = random(-21, 21);
    vpy = random(-30, -18);
  }

  puntos.add(new Punto(px, py, vpx, vpy, random(360)));
}

// CLASE PUNTO
class Punto {

  float x, y;
  float px, py;
  float vx, vy;
  float tono;
  float velColor;

  color col;

  boolean dentro = false;
  int ultimoChoque = -1000;

  Punto(float x, float y, float vx, float vy, float tono) {

    this.x = x;
    this.y = y;

    this.px = x;
    this.py = y;

    this.vx = vx;
    this.vy = vy;

    this.tono = tono;
    this.velColor = random(0.6, 1.3);

    this.col = color(tono, 100, 100);
  }
}
