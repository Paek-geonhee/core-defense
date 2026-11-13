// 중앙 방어전 — Processing 4 (Java 모드)
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Item> items = new ArrayList<Item>();
float cx, cy, angle = -HALF_PI, elapsed, spawnTimer, shotTimer, previous;
int score, hp, state = 0; // 0: 대기, 1: 플레이, 2: 게임 오버
boolean aiming = false;

void settings() { size(960, 600); }
void setup() { surface.setTitle("중앙 방어전"); cx=width/2; cy=height/2; textFont(createFont("Malgun Gothic", 16)); previous=millis(); }
void resetGame() { enemies.clear(); bullets.clear(); items.clear(); score=0; hp=5; elapsed=0; spawnTimer=.7; shotTimer=0; angle=-HALF_PI; aiming=false; state=1; previous=millis(); }
void draw() {
  float dt=min((millis()-previous)/1000.0, .05); previous=millis();
  if (state==1) updateGame(dt);
  background(12,21,36); stroke(23,39,59); strokeWeight(1);
  for (int x=0;x<width;x+=40) line(x,0,x,height);
  for (int y=0;y<height;y+=40) line(0,y,width,y);
  noFill(); stroke(32,57,75); for (int r=100;r<=280;r+=90) ellipse(cx,cy,r*2,r*2);
  fill(132,152,182); noStroke(); textAlign(LEFT); textSize(11); text("SCORE",26,31); text("CORE INTEGRITY",26,77); textAlign(RIGHT); text("SURVIVAL",width-26,31);
  fill(244,249,255); textSize(25); text(nf(score,5),26+textWidth(nf(score,5)),58); text(int(elapsed)+"s",width-26,58); textAlign(LEFT);
  for (int i=0;i<5;i++) { fill(i<hp?color(121,235,216):color(51,68,84)); rect(26+i*23,86,17,6); }
  for (Item item:items) item.display(); for (Enemy enemy:enemies) enemy.display(); for (Bullet bullet:bullets) bullet.display();
  pushMatrix(); translate(cx,cy); rotate(angle); noStroke(); fill(140,238,227); rect(12,-5,25,10); fill(25,47,63); stroke(137,238,226); strokeWeight(3); ellipse(0,0,46,46); noStroke(); fill(170,255,239); ellipse(0,0,16,16); popMatrix();
  if (state!=1) drawOverlay();
}
void updateGame(float dt) {
  elapsed+=dt; spawnTimer-=dt; shotTimer-=dt;
  if (spawnTimer<=0) { int side=int(random(4)); float x=side==0?-20:side==1?width+20:random(width), y=side==2?-20:side==3?height+20:random(height); enemies.add(new Enemy(x,y)); spawnTimer=max(.16,.95-elapsed*.006)*random(.75,1.2); }
  if (aiming && shotTimer<=0) { bullets.add(new Bullet(angle)); shotTimer=.14; }
  for (int i=bullets.size()-1;i>=0;i--) {
    Bullet b=bullets.get(i); b.x+=b.vx*dt; b.y+=b.vy*dt; boolean hit=false;
    for (int j=items.size()-1;j>=0;j--) { Item item=items.get(j); if (dist(b.x,b.y,item.x,item.y)<13) { activate(item); items.remove(j); hit=true; break; } }
    if (!hit) for (int j=enemies.size()-1;j>=0;j--) { Enemy e=enemies.get(j); if (dist(b.x,b.y,e.x,e.y)<e.r+4) { kill(j,true); hit=true; break; } }
    if (hit || b.x< -10 || b.x>width+10 || b.y< -10 || b.y>height+10) bullets.remove(i);
  }
  for (int i=enemies.size()-1;i>=0;i--) { Enemy e=enemies.get(i); float a=atan2(cy-e.y,cx-e.x); e.x+=cos(a)*e.speed*dt; e.y+=sin(a)*e.speed*dt; if (dist(e.x,e.y,cx,cy)<e.r+23) { enemies.remove(i); hp--; if (hp<=0) { state=2; aiming=false; break; } } }
  for (int i=items.size()-1;i>=0;i--) { Item item=items.get(i); item.life-=dt; if (item.life<=0) items.remove(i); }
}
void kill(int index, boolean drop) { Enemy e=enemies.get(index); score+=10; if (drop && random(1)<.18) items.add(new Item(e.x,e.y,int(random(3)))); enemies.remove(index); }
void activate(Item item) { if (item.type==0) hp=min(5,hp+1); else if (item.type==2) score+=100; else for (int i=enemies.size()-1;i>=0;i--) { Enemy e=enemies.get(i); if (dist(e.x,e.y,item.x,item.y)<125) kill(i,false); } }
void drawOverlay() { noStroke(); fill(6,12,23,210); rect(0,0,width,height); textAlign(CENTER); fill(125,229,223); textSize(12); text("HOLD YOUR GROUND",cx,180); fill(243,247,255); textSize(36); text(state==2?"방어선이 무너졌습니다":"중앙을 사수하세요",cx,235); textSize(16); fill(180,198,218); if (state==2) { text("최종 점수 "+score+"점  ·  생존 시간 "+int(elapsed)+"초",cx,280); text("R: 다시 시작     Q: 게임 종료",cx,360); } else { text("마우스를 누른 채 방향을 조준하면 자동으로 발사합니다.",cx,280); text("아이템을 탄환으로 맞혀 획득하세요.",cx,308); text("초록: 체력 +1    주황: 주변 적 처치    노랑: 점수 +100",cx,345); text("ENTER 또는 SPACE: 게임 시작",cx,400); } textAlign(LEFT); }
void mousePressed() { if (state==1) { aiming=true; angle=atan2(mouseY-cy,mouseX-cx); } }
void mouseDragged() { if (state==1 && aiming) angle=atan2(mouseY-cy,mouseX-cx); }
void mouseReleased() { aiming=false; }
void keyPressed() { if (state==0 && (key==ENTER || key==RETURN || key==' ')) resetGame(); else if (state==2 && (key=='r'||key=='R')) resetGame(); else if (state==2 && (key=='q'||key=='Q')) exit(); }
class Enemy { float x,y,r,speed; Enemy(float x,float y) { this.x=x; this.y=y; r=random(10,15); speed=random(40,60)+min(elapsed,145); } void display() { noStroke(); fill(255,128,111); ellipse(x,y,r*2,r*2); fill(102,47,55); ellipse(x,y,r*.7,r*.7); } }
class Bullet { float x,y,vx,vy; Bullet(float a) { x=cx+cos(a)*32; y=cy+sin(a)*32; vx=cos(a)*560; vy=sin(a)*560; } void display() { noStroke(); fill(186,253,244); ellipse(x,y,8,8); } }
class Item { float x,y,life=12; int type; Item(float x,float y,int type) { this.x=x; this.y=y; this.type=type; } void display() { pushMatrix(); translate(x,y); rotate(QUARTER_PI); rectMode(CENTER); noStroke(); fill(type==0?color(117,237,180):type==1?color(255,157,103):color(255,224,121)); rect(0,0,16,16); rectMode(CORNER); popMatrix(); fill(20,33,43); textAlign(CENTER); textSize(12); text(type==0?"+":type==1?"*":"$",x,y+4); textAlign(LEFT); } }
