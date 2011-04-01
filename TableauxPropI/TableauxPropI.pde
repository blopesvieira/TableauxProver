import controlP5.*;

ArrayList nos = new ArrayList();
ArrayList linhas = new ArrayList();
int[][] ramos = new int[25][25];
int countnos = 0;
int maxnos = 0;
int countramos = 0;
int constParam = -1;
ArrayList constantesCriadas = new ArrayList();
PFont myfont=createFont("Arial", 12);
MobileRectangle[] border = new MobileRectangle[20];
MobileRectangle nopressed;
char and = '&';
char or = '|';
char not = '~';
char implies = '=';
String exists = "EX";
String forall = "ALL";
color cm = color(128,0,0);
color cf = color(50, 0, 70);

int alt = 10;
float ratiobin = 0.75;
float vertsep = 1.7;
int labelnos = 0;

ControlP5 controlP5;
Textfield txtInputFormula;
Button btnTableaux;
public int inputColor = 200;
public int backgroundColor = 100;
int defaultColor;

void setup() {
  size(800,800);
  smooth();
  frameRate(25);
  controlP5 = new ControlP5(this);
  txtInputFormula = controlP5.addTextfield("Formula", 10, 15, 380, 16);
  btnTableaux = controlP5.addButton("Tableaux", 0, 400, 15, 45, 19);
  txtInputFormula.setFocus(true);
  txtInputFormula.setAutoClear(false);
  defaultColor = txtInputFormula.getColor().getBackground();
}

public void Formula(String textField) {
  println("Textfield command");
  startTableaux(txtInputFormula.getText());
}

public void Tableaux(int value) {
  println("Button command");
  startTableaux(txtInputFormula.getText());
}

void startTableaux(String formula) {
  formula = removeWhiteSpace(formula.toUpperCase());
  if(validInputFormula(formula)) {
    nos = new ArrayList();
    linhas = new ArrayList();
    ramos = new int[25][25];
    countnos = 0;
    maxnos = 0;
    countramos = 0;
    constParam = -1;
    constantesCriadas = new ArrayList();
    txtInputFormula.setColorBackground(defaultColor);
    formula = changeSymbol(formula, '(', '[');
    formula = changeSymbol(formula, ')', ']');
    MobileRectangle re = new MobileRectangle(300, 120, "F" + formula + "0", 250, 0, 250, 10, true);
    nos.add(re);
    border[0] = re;
    ramos[0][0] = re.label;
    maxnos = 1;
    println("setup"+" h "+ height );
    countramos++;
  }
  else {
    txtInputFormula.setColorBackground(color(90, 0, 0));
  }
}

boolean validInputFormula(String formula) {
  int l = formula.length() - 1;
  int count;
  int i, j;

  if(formula.charAt(0) != '(' || formula.charAt(l) != ')') return false;
  if(formula.charAt(1) == '~') {
    switch(formula.charAt(2)) {
      case '=' :
      case '&' :
      case '|' :
      case '~' :
      case ')' : return false;
    }
    i = 2;
    if(formula.charAt(2) == '(') {
      count = 1;
      do {
        i++;
        switch(formula.charAt(i)) {
          case '(' : count++;
                     break;
          case ')' : count--;
        }
        if(i > l) return false;
      } while(count > 0);
      if(!validInputFormula(formula.substring(2, i + 1))) return false;
    }
    if(i + 1 != l) return false;
  }
  else {
    if(formula.substring(1, 4).equals("ALL")) {
      if(formula.charAt(4) != ' ') return false;
      switch(formula.charAt(5)) {
        case '=' :
        case '&' :
        case '|' :
        case '~' :
        case ',' :
        case ')' : return false;
      }
      i = 6;
      if(formula.charAt(6) == '(') {
        count = 1;
        do {
          i++;
          switch(formula.charAt(i)) {
            case '(' : count++;
                       break;
            case ')' : count--;
          }
          if(i > l) return false;
        } while(count > 0);
        if(!validInputFormula(formula.substring(6, i + 1))) return false;
      }
      if(i + 1 != l) return false;
    }
    else if(formula.substring(1, 3).equals("EX")) {
           if(formula.charAt(3) != ' ') return false;
           switch(formula.charAt(4)) {
             case '=' :
             case '&' :
             case '|' :
             case '~' :
             case ')' : return false;
           }
           i = 5;
           if(formula.charAt(5) == '(') {
             count = 1;
             do {
               i++;
               switch(formula.charAt(i)) {
                  case '(' : count++;
                            break;
                 case ')' : count--;
               }
               if(i > l) return false;
             } while(count > 0);
             if(!validInputFormula(formula.substring(5, i + 1))) return false;
           }
           if(i + 1 != l) return false;
         }
         else {
            if(formula.charAt(1) == '=' || formula.charAt(1) == '&' || formula.charAt(1) == '|' ) {
              switch(formula.charAt(2)) {
                case '=' :
                case '&' :
                case '|' :
                case '~' :
                case ')' : return false;
              }
              i = 2;
              if(formula.charAt(2) == '(') {
                count = 1;
                do {
                  i++;
                  switch(formula.charAt(i)) {
                    case '(' : count++;
                               break;
                    case ')' : count--;
                  }
                  if(i > l) return false;
                } while(count > 0);
                if(!validInputFormula(formula.substring(2, i + 1))) return false;
              }
              switch(formula.charAt(i + 1)) {
                case '=' :
                case '&' :
                case '|' :
                case ')' : return false;
              }
              j = i += 1;
              if(formula.charAt(j) == '(') {
                count = 1;
                do {
                  j++;
                  switch(formula.charAt(j)) {
                    case '(' : count++;
                               break;
                    case ')' : count--;
                  }
                  if(j > l) return false;
                } while(count > 0);
                if(!validInputFormula(formula.substring(i, j + 1))) return false;
              }
              if (j + 1 != l) return false;
            }
            else {
              if(formula.charAt(2) != ' ') return false;
              switch(formula.charAt(3)) {
                case '=' :
                case '&' :
                case '|' :
                case '~' :
                case '(' :
                case ')' : return false;
              }
              if(l > 5) return false;
            }
         }
       }
  println("Formula " + formula + "is ok!");
  return true;
}

String removeWhiteSpace(String input) {
  int l = input.length();
  int i = 0;
  boolean remove = false;
  while(i < l) {
    if(input.charAt(i) == ' ') {
      if(i >= 4) {
        if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == '=' || input.charAt(i - 1) == '&' || input.charAt(i - 1) == '|' || input.charAt(i - 1) == '~')) && !input.substring(i - 3, i).equals("ALL") && !input.substring(i - 2, i).equals("EX")) remove = true;
      }
      else if(i < 2) {
        remove = true;
      }
        else if(i == 2) {
          if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == '=' || input.charAt(i - 1) == '&' || input.charAt(i - 1) == '|' || input.charAt(i - 1) == '~'))) remove = true;
        }
          else if(i == 3) {
            if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == '=' || input.charAt(i - 1) == '&' || input.charAt(i - 1) == '|' || input.charAt(i - 1) == '~')) && !input.substring(i - 2, i).equals("EX")) remove = true;
          }
    }
    if(remove) {
      if(i > 0 && i < l - 1) input = input.substring(0, i) + input.substring(i + 1, l);
      else if(i == 0) input = input.substring(i + 1, l);
           else if(i == l - 1) input = input.substring(0, l - 1);
      l = input.length();
      remove = false;
    }
    else i++;
  }
  println("Input space normalized: " + input);
  return input;
}

String changeSymbol(String input, char from, char to) {
  int i;
  int l = input.length();
  if(l > 0) {
    if(input.charAt(0) == from && l > 1) input =  to + input.substring(1, l);
    for(i = 1; i < l - 1; i++)
      if(input.charAt(i) == from) input = input.substring(0, i) + to + input.substring(i + 1, l);
    if(input.charAt(l - 1) == from) input = input.substring(0, l - 1) + to;
  }
  println("Changing " + from + " to " + to + ": " + input);
  return input;
}

void draw() {
  background(0);
  textFont(myfont);
  fill(backgroundColor);
  rect(0, 0, width, 100);
  for(int i = 0; i < nos.size(); i++) { 
    MobileRectangle re = (MobileRectangle) nos.get(i); 
    re.display(); 
  }
}

class MobileRectangle {
  int x, y, x1, x2, y1, y2;
  float l1, l2;
  color c, c1;
  String s;
  int label;
  int instancesCounter;
  boolean expanded;
  boolean first;
 
  MobileRectangle(int x, int y, String t, int x1, int y1, int x2, int y2, boolean first) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.c1 = color(0, 128, 128);
    this.x = x;
    this.y = y;
    this.c = color(128, 128, 0);
    this.s = t;
    countnos++; 
    this.label = countnos;
    this.instancesCounter = 0;
    this.expanded = false;
    this.first = first;
  }

  void expandNode() {
    this.expanded = true;
  }

  boolean canExpand() {
    return !this.expanded;
  }

  void marcado() {
    c = cm;
  }

  void finished() {
    if(!this.isFirst()) c = defaultColor;
  }

  void update(int X, int Y) {
    this.x = X - round(l1/2);
    this.y = Y - round(l2/2);
  }

  void display() {
    fill(c);
    stroke(c1);
    textFont(myfont);
    text(label + " " + s, x, y);
    line(x1, y1, x2, y2);
  }

  boolean isFirst() {
    return this.first;
  }

}

void mousePressed() {
  MobileRectangle folha;
  exibedados();
  int indice=-1; 
  println("nos.size " + nos.size());
  for(int i = 0; i < nos.size(); i++) {
    MobileRectangle re = (MobileRectangle) nos.get(i);
    println("Node data: re.x re.y re.s" + re.x + " " + re.y + " " + re.s + " " + re.s.length()+ " " + mouseX + " " + mouseY);
    if((re.x < mouseX) && (mouseX < re.x+12 * (re.s.length())) && (re.y - alt < mouseY) && (mouseY < re.y+alt)) {
      println("Index found = " + i);
      indice = i;
    }
  }
  if(indice != -1) {
    println("Index " + indice);
    nopressed = (MobileRectangle) nos.get(indice);
    if(nopressed.canExpand()) {
      println("Ok, first time on this node... expanding!");
      if(!existential(nopressed.s) && !universal(nopressed.s) && (branches(nopressed.s) || nopressed.isFirst())) nopressed.expandNode();
      println("nopressed "+ nopressed.s + " " + nopressed.y + " "+ nopressed.label); 
      if(mouseButton == RIGHT) {
        int totalramos = countramos;
        for(int i = 0; i < totalramos; i++) {
          println("Entering if statement: "+ " logbin = maxnos = "+ maxnos + " countramos= " + totalramos);
          int maximonosramo = maxnos;
          for(int j = 0; j <= maximonosramo; j++) {
            println("ramos[][] = " + ramos[i][j] + " i=" + i + " j=" + j);
            if(ramos[i][j] == nopressed.label) {
              if(branches(nopressed.s)) {
                nopressed.marcado();
                folha = border[i];
                println("Border node = " + folha.label + " i= " + i);
                MobileRectangle um = new MobileRectangle(folha.x - 6 * (folha.s).length(), folha.y + 40, res1(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x-3 * (folha.s).length(), folha.y + 35, false);
                nos.add(um);
                MobileRectangle dois = new MobileRectangle(folha.x + 6 * (folha.s).length(), folha.y + 40, res2(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x + 3 * (folha.s).length(), folha.y + 35, false);
                nos.add(dois);
                ramos[i][maxnos+1] = um.label;
                border[i]=um;
                for (int k =0 ; k<= maxnos; k++) {
                  ramos[countramos][k] = ramos[i][k];
                }
                ramos[countramos][maxnos+1] = dois.label;
                border[countramos] = dois;
                countramos++;
                maxnos++;
              }
              else {
                if(notbranches(nopressed.s)) {
                  nopressed.marcado();
                  folha = border[i];
                  println(" No da border = " + folha.label + " i= " + i);
                  MobileRectangle um= new MobileRectangle(folha.x, folha.y + 40, res1(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x, folha.y + 40, false);
                  nos.add(um);
                  MobileRectangle dois = new MobileRectangle(folha.x, folha.y + 80, res2(nopressed.s) + nopressed.label, folha.x, folha.y + 40, folha.x, folha.y + 80, false);
                  nos.add(dois);
                  ramos[i][maxnos+1] = um.label;
                  ramos[i][maxnos+2] = dois.label;
                  border[i] = dois;
                  maxnos++;                         
                  maxnos++;
                }                   
                else {
                  if(existential(nopressed.s)) {
                    nopressed.marcado();
                    print("existencial");
                    folha = border[i];
                    MobileRectangle um = new MobileRectangle(folha.x, folha.y + 40, exist(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x, folha.y + 40, false);
                    nos.add(um);
                    ramos[i][maxnos+1] = um.label;
                    border[i] = um;
                    maxnos++; 
                  }                          
                  else{
                    if(universal(nopressed.s)) {
                      print("universal");
                      folha = border[i];
                      MobileRectangle um = new MobileRectangle(folha.x, folha.y + 40, forall(nopressed.s, nopressed) + nopressed.label, folha.x, folha.y, folha.x, folha.y + 40, false);
                      nos.add(um);
                      ramos[i][maxnos+1] = um.label;
                      border[i] = um;
                      maxnos++; 
                    }
                    else {
                      if(negation(nopressed.s)) {
                        nopressed.marcado();
                        folha = border[i];
                        println(" No da border = "+folha.label + " i= "+i);
                        MobileRectangle um = new MobileRectangle(folha.x, folha.y+40, uno(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x, folha.y + 40, false);
                        nos.add(um);
                        ramos[i][maxnos+1] = um.label;
                        border[i] = um; 
                        maxnos++;
                      } else nopressed.finished();
                    }
                  }
                }
              }
            }
            exibedados();
          }
        }
      }
    }
    else {
      println("Node already expanded... nothing more to do.");
      nopressed.finished();
    }
  }
}
   
boolean existential(String s){
  print("testando exist");
  String[] m = match(s, "(.)\\[(EX|ALL)\\s+([^\\s])\\s*(\\[.+\\]|.)\\]");
  if(m != null) {
    println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
    if(((m[1].equals("F")) && (m[2].equals("ALL"))) || ((m[1].equals("V")) &&(m[2].equals("EX")))) return (true);
    else return false;
  }
  else return false;
}   
     
boolean negation(String s) {
  print("testando negation");
  String[] m = match(s, "(.)\\[(~).+\\]");
  if(m!=null) {
    println(m[0] + "1" + m[1]);
    return true;
  }
  else return false;
}

boolean universal(String s) {
  print("testando universal");
  String[] m = match(s, "(.)\\[(EX|ALL)\\s+([^\\s])\\s*(\\[.+\\]|.)\\]");
  if(m!=null) {
    println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
    if (((m[1].equals("V")) && (m[2].equals("ALL"))) || ((m[1].equals("F")) &&(m[2].equals("EX")))) return (true);
    else return false;
  }
  else return false;
}        

boolean branches(String s) { 
  String[] m = match(s, "(.)\\[(.)(\\[.+\\]|.)(\\[.+\\]|.)\\]");
  if(m!=null) {
    if(((m[1].equals("F")) && (m[2].equals("&"))) || ((m[1].equals("V")) &&(m[2].equals("|"))) || ((m[1].equals("V")) &&(m[2].equals("=")))) {
      return true;
    }
    else return false;
  }
  else return false;
}   

boolean notbranches(String s) {
  String [] m = match(s, "(.)\\[(&|\\||=).+");
  if(m!=null) {
    println("casou no notbranches");    
    if(((m[1].equals("V")) && (m[2].equals("&"))) || ((m[1].equals("F")) &&(m[2].equals("|"))) || ((m[1].equals("F")) &&(m[2].equals("=")))) {
      return true;
    }
    else return false;
  }
    else return false;
}

String uno(String s) {
  String[] m = match(s, "(.)\\[(.)(.+)\\]");
  println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3]);
  if(m[2].equals("~")) return (inv(m[1]) + m[3]);
  else return null;
}
   
String exist(String s) {
  String[] m = match(s, "(.)\\[(EX|ALL)\\s+([^\\s])\\s*(\\[.+\\]|.)\\]");
  println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
  constParam++;
  constantesCriadas.add("c" + constParam);
  return(m[1] + m[4].replace(m[3], "c" + constParam));
}

String forall(String s, MobileRectangle originalFormula) {
  String[] m = match(s, "(.)\\[(EX|ALL)\\s+([^\\s])\\s*(\\[.+\\]|.)\\]");
  println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
  if (constantesCriadas.size() == 0) {
    constParam++;
    constantesCriadas.add("c" + 0);
    return(m[1] + m[4].replace(m[3], "c" + 0));
  }
  else {
    if(constantesCriadas.size() < originalFormula.instancesCounter) {
      constParam++;
      constantesCriadas.add("c" + constParam);
      originalFormula.instancesCounter++;
      return(m[1] + m[4].replace(m[3],"c" + constParam));
    }
    else {
      int instance=originalFormula.instancesCounter;
      originalFormula.instancesCounter++;
      return(m[1] + m[4].replace(m[3], "c" + instance));
    }
  }                
}    

String res1(String s) {
  int i = 4;
  String arg1 = "";
  int p = 0;
  if(s.charAt(3) != '[') arg1 = s.substring(3, 4);
  else {
    p = 1;
    arg1 = arg1 + "[";
  }
  println("=> " + s + " " + arg1 + " " + p);
  while(p != 0) {
    if(s.charAt(i) == '[') p++;
    else if (s.charAt(i)==']') p = p - 1;
    arg1 = arg1+s.charAt(i);
    i++;
  } 
  String [] m = match(s, "(.)\\[(.)(\\[.+\\]|.)(\\[.+\\]|.)\\]");
  if (m[2].equals("|")) return(m[1] + arg1);
  if (m[2].equals("&")) return(m[1] + arg1);
  if (m[2].equals("=")) return(inv(m[1]) + arg1);
  else return null;  
}
 
String inv(String c) {
  if(c.equals("V")) return "F";
  else return "V";
}

String res2(String s) {
  String [] k = match(s, "(.+)\\][0-9]+");
  s = k[1];
  println("s -->"+s);
  int i = s.length() - 1;
  String arg2 = "";
  int p = 0;
  if(s.charAt(i) != ']') {
    arg2=s.substring(i, i + 1);
  }
  else {
    p = 1;
    arg2 = "]" + arg2;
    i = i - 1;
  }
  println("=> " + s.substring(1, i + 1) + " " + arg2 + " " + p + " i=" + i);
  while(p != 0) {
    if (s.charAt(i)==']') p++;
    else if(s.charAt(i) == '[') p = p - 1;
    arg2 = s.charAt(i) + arg2;
    i = i - 1;
    println(s.substring(1, i + 1) + " p=" + p + " char=" + s.charAt(i));
  };
  String[] m = match(s, "(.)\\[(.).+");
  if(m[2].equals("|")) return(m[1] + arg2);
  if(m[2].equals("&")) return(m[1] + arg2);
  if(m[2].equals("=")) return(m[1] + arg2);
  return null;   
}
  
void exibedados() {
  println("SAIDA ==>"+ " maxnos = "+ maxnos + " countramos= "+ countramos);
  for(int i = 0; i < countramos; i++) {
    for(int j = 0; j <= maxnos; j++) {
      println(" ramos[][] "+ ramos[i][j] + " i=" + i + " j=" + j);
    }
  } 
  for(int k = 0; k < countramos; k++) {
    println("border com " + " k=" + k + " =" + border[k].label);
  } 
}

void mouseDragged() {
  if(!nopressed.isFirst()) {
    nopressed.y = mouseY;
    nopressed.x = mouseX;
    nopressed.x2 = mouseX;
    nopressed.y2 = mouseY;
  }
  for(int i = 0; i < countramos; i++) {
    for(int j = 0; j <= maxnos; j++) {
      if(ramos[i][j] == nopressed.label) {
        for(int k = 0; k < nos.size(); k++) {
          MobileRectangle re = (MobileRectangle) nos.get(k);
          if(re.label == ramos[i][j+1]) {
            re.x1 = mouseX;
            re.y1 = mouseY;
          }
        }
      }
    }
  }
}
