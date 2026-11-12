
ArrayList<Punto> puntos;

PGraphics pintura;

int anchoLienzo = 1080;
int altoLienzo = 1920;
float escala = 0.5;

float grosor = 20;
float velocidad = 10;

// EXPORTACIÓN
int totalFotogramas = 250;
int fotograma = 0;

void setup() {

  size(540, 960);
  smooth(8);
  frameRate(25);

  puntos = new ArrayList<Punto>();

  colorMode(HSB, 360, 100, 100);

  // Crear carpeta de exportación
  new java.io.File(sketchPath("frames")).mkdirs();

  pintura = createGraphics(anchoLienzo, altoLienzo);
  pintura.smooth(8);

  pintura.beginDraw();
  pintura.colorMode(RGB, 255);
  pintura.background(255, 255, 255);
  pintura.noStroke();
  pintura.endDraw();

  for (int i = 0; i < 40; i++) {
    crearPunto();
  }
}

void draw() {

  for (Punto p : puntos) {
    p.mover();
  }

  comprobarColisiones();

  for (Punto p : puntos) {
    p.dibujar();
  }

  // Fondo blanco puro
  colorMode(RGB, 255);
  background(255, 255, 255);

  // Mostrar lienzo al 50%
  image(pintura, 0, 0, width, height);

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

void crearPunto() {

  float px = 0;
  float py = 0;
  float vx = 0;
  float vy = 0;

  int lado = int(random(4));

  if (lado == 0) {
    px = -grosor;
    py = random(altoLienzo);
    vx = velocidad;

  } else if (lado == 1) {
    px = anchoLienzo + grosor;
    py = random(altoLienzo);
    vx = -velocidad;

  } else if (lado == 2) {
    px = random(anchoLienzo);
    py = -grosor;
    vy = velocidad;

  } else {
    px = random(anchoLienzo);
    py = altoLienzo + grosor;
    vy = -velocidad;
  }

  puntos.add(new Punto(px, py, vx, vy));
}

void comprobarColisiones() {

  for (int i = 0; i < puntos.size(); i++) {

    for (int j = i + 1; j < puntos.size(); j++) {

      Punto a = puntos.get(i);
      Punto b = puntos.get(j);

      float dx = b.x - a.x;
      float dy = b.y - a.y;

      float solX = grosor - abs(dx);
      float solY = grosor - abs(dy);

      if (solX > 0 && solY > 0) {

        if (solX < solY) {

          float separacion = solX / 2.0 + 0.2;

          if (dx >= 0) {
            a.x -= separacion;
            b.x += separacion;
          } else {
            a.x += separacion;
            b.x -= separacion;
          }

        } else {

          float separacion = solY / 2.0 + 0.2;

          if (dy >= 0) {
            a.y -= separacion;
            b.y += separacion;
          } else {
            a.y += separacion;
            b.y -= separacion;
          }
        }

        a.girar();
        b.girar();
      }
    }
  }
}

class Punto {

  float x, y;
  float px, py;

  float vx, vy;

  float tono;
  float velColor = 0.5;

  color col;

  Punto(float x, float y, float vx, float vy) {

    this.x = x;
    this.y = y;

    this.px = x;
    this.py = y;

    this.vx = vx;
    this.vy = vy;

    tono = random(360);
    col = color(tono, 100, 100);
  }

  void mover() {

    px = x;
    py = y;

    x += vx;
    y += vy;

    // Reaparecer por el lado contrario
    if (x < -grosor) {
      x = anchoLienzo + grosor;
    }

    if (x > anchoLienzo + grosor) {
      x = -grosor;
    }

    if (y < -grosor) {
      y = altoLienzo + grosor;
    }

    if (y > altoLienzo + grosor) {
      y = -grosor;
    }

    // Cambio continuo de color
    tono = (tono + velColor) % 360;

    col = color(tono, 100, 100);
  }

  void girar() {

    float temp = vx;

    vx = -vy;
    vy = temp;
  }

  void dibujar() {

    pintura.beginDraw();

    pintura.colorMode(HSB, 360, 100, 100);
    pintura.noStroke();
    pintura.fill(col);
    pintura.rectMode(CENTER);

    // Trazos permanentes
    if (dist(px, py, x, y) < grosor * 2) {
      pintura.rect(x, y, grosor, grosor);
    }

    pintura.endDraw();

    // Cuadrados visibles
    noStroke();
    fill(col);
    rectMode(CENTER);

    rect(
      x * escala,
      y * escala,
      grosor * escala,
      grosor * escala
    );
  }
}
