import controlP5.*;

ArrayList nos = new ArrayList();
ArrayList linhas = new ArrayList();
int[][] ramos = new int[25][25];
int countnos = 0;
int maxnos = 0;
int countramos = 0;
int constParam = -1;
ArrayList constantesCriadas = new ArrayList();
PFont myfont = createFont("Arial", 12);
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

int maxUndo = 30;
ArrayList[] nosUndo = new ArrayList[maxUndo];
ArrayList[] linhasUndo = new ArrayList[maxUndo];
int[][][] ramosUndo = new int[maxUndo][25][25];
int[] countnosUndo = new int[maxUndo];
int[] maxnosUndo = new int[maxUndo];
int[] countramosUndo = new int[maxUndo];
int[] constParamUndo = new int[maxUndo];
ArrayList[] constantesCriadasUndo = new ArrayList[maxUndo];
MobileRectangle[][] borderUndo = new MobileRectangle[maxUndo][20];
MobileRectangle[] undo = new MobileRectangle[maxUndo];
int undoPos = -1;

int alt = 10;
float ratiobin = 0.75;
float vertsep = 1.7;
int labelnos = 0;

ControlP5 controlP5;
Textfield txtInputFormula;
Button btnTableaux;
Button btnUndo;
Radio rdoNotation;
public boolean prefix;
public int inputColor = 200;
public int backgroundColor = 100;
int defaultColor;
int sizeX = 800;
int sizeY = 800;

void setup() {
  size(sizeX,sizeY);
  smooth();
  frameRate(25);
  controlP5 = new ControlP5(this);
  txtInputFormula = controlP5.addTextfield("Formula", 10, 15, 380, 16);
  btnTableaux = controlP5.addButton("Tableaux", 0, 400, 15, 45, 19);
  btnUndo = controlP5.addButton("Undo", 0, 450, 15, 45, 19);
  rdoNotation = controlP5.addRadio("Notation", 10, 60);
  rdoNotation.add("Infix", 0);
  rdoNotation.add("Prefix", 1);
  prefix = false;
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

public void Undo(int value) {
  int pos = undoPos--;
  while (pos > maxUndo) pos = pos - maxUndo;
  if(pos >= 0) {
    println("Undoing last expansion...");
    nos = new ArrayList();
    for(int i = 0; i < nosUndo[pos].size(); i++) nos.add(nosUndo[pos].get(i));
    linhas = new ArrayList();
    for(int i = 0; i < linhasUndo[pos].size(); i++) linhas.add(linhasUndo[pos].get(i));
    ramos = new int[25][25];
    for(int i = 0; i < countramosUndo[pos]; i++) {
      for(int j = 0; j <= maxnosUndo[pos]; j++) {
        ramos[i][j] = ramosUndo[pos][i][j];
      }
    }
    border = new MobileRectangle[20];
    for(int i = 0; i < countramosUndo[pos]; i++) {
      border[i] = borderUndo[pos][i];
    }
    countnos = countnosUndo[pos];
    maxnos = maxnosUndo[pos];
    countramos = countramosUndo[pos];
    constParam = constParamUndo[pos];
    constantesCriadas = new ArrayList();
    for(int i = 0; i < constantesCriadasUndo[pos].size(); i++) constantesCriadas.add(constantesCriadasUndo[pos].get(i));
    undo[pos].undo();
  }
  else {
    undoPos = -1;
    println("Nothing to undo...");
  }
}

void undoAdd(MobileRectangle node) {
  int pos = ++undoPos;
  while (pos > maxUndo) pos = pos - maxUndo;
  nosUndo[pos] = new ArrayList(nos.size());
  for(int i = 0; i < nos.size(); i++) nosUndo[pos].add(nos.get(i));
  linhasUndo[pos] = new ArrayList(linhas.size());
  for(int i = 0; i < linhas.size(); i++) linhasUndo[pos].add(linhas.get(i));
  ramosUndo[pos] = new int[25][25];
  for(int i = 0; i < countramos; i++) {
    for(int j = 0; j <= maxnos; j++) {
      ramosUndo[pos][i][j] = ramos[i][j];
    }
  }
  borderUndo[pos] = new MobileRectangle[20];
  for(int i = 0; i < countramos; i++) {
    borderUndo[pos][i] = border[i];
  }
  countnosUndo[pos] = countnos;
  maxnosUndo[pos] = maxnos;
  countramosUndo[pos] = countramos;
  constParamUndo[pos] = constParam;
  constantesCriadasUndo[pos] = new ArrayList(constantesCriadas.size());
  for(int i = 0; i < constantesCriadas.size(); i++) constantesCriadasUndo[pos].add(constantesCriadas.get(i));
  undo[pos] = nopressed;
  println("Old status saved for undo...");
}

void Notation(int id) {
  switch(id) {
    case 0: prefix = false;
    case 1: prefix = true;
  }
}

void startTableaux(String formula) {
  MobileRectangle re;
  if(!prefix) {
    formula = removeWhiteSpaceInfix(formula);
    formula = infix2prefix(formula);
    println("Prefix formula = " + formula);
  }
  else formula = removeWhiteSpace(formula);
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
    re = new MobileRectangle(300, 120, "F" + formula + "0", 250, 0, 250, 10, true);
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

String infix2prefix(String formula) {
  int i = 1;
  int j, k;
  int count;
  String left, right;
  if(formula.charAt(i) == not) {
    if(formula.charAt(i + 1) == '(') return("(" + not + infix2prefix(formula.substring(i + 1, formula.length() - 1)) + formula.substring(formula.length() - 1, formula.length()));
    else return(formula);
  }
  if(formula.length() > 6) {
    if(formula.substring(1, 4).equals(forall)) return(infix2prefix(formula.substring(6, formula.length() - 1)));
    if(formula.substring(1, 3).equals(exists)) return(infix2prefix(formula.substring(5, formula.length() - 1)));
  }
  if(formula.length() == 5 && (formula.indexOf(str(implies)) == -1 && formula.indexOf(str(and)) == -1 && formula.indexOf(str(or)) == -1)) return(formula);
  j = i + 1;
  if(formula.charAt(i) == '(') {
    count = 1;
    while(count > 0) {
      if(formula.charAt(j) == ')') count--;
      else if(formula.charAt(j) == '(') count++;
      j++;
    }
    left = infix2prefix(formula.substring(i, j));
  }
  else left = formula.substring(i, j);
  i = j + 1;
  k = i + 1;
  if(formula.charAt(i) == '(') {
    count = 1;
    while(count > 0) {
      if(formula.charAt(k) == ')') count--;
      else if(formula.charAt(k) == '(') count++;
      k++;
    }
    right = infix2prefix(formula.substring(i, k));
  }
  else right = formula.substring(i, k);
  return("(" + formula.substring(j, j + 1) + left + right + ")");
}

String prefix2infix(String formula) {
  int i = 1;
  int j, k;
  int count;
  String left, right;
  if(formula.charAt(i) == '~') {
    if(formula.charAt(i + 1) == '(') return("(" + not + prefix2infix(formula.substring(i + 1, formula.length() - 1)) + ")");
    else return(formula);
  }
  i++;
  j = i + 1;
  if(formula.charAt(i) == '(') {
    count = 1;
    while(count > 0) {
      if(formula.charAt(j) == ')') count--;
      else if(formula.charAt(j) == '(') count++;
      j++;
    }
    left = prefix2infix(formula.substring(i, j));
  }
  else left = formula.substring(i, j);
  i = j;
  k = i + 1;
  if(formula.charAt(i) == '(') {
    count = 1;
    while(count > 0) {
      if(formula.charAt(k) == ')') count--;
      else if(formula.charAt(k) == '(') count++;
      k++;
    }
    right = prefix2infix(formula.substring(i, k));
  }
  else right = formula.substring(i, k);
  return("(" + left + formula.substring(1, 2) + right + ")");
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
    case ')' : 
      return false;
    }
    i = 2;
    if(formula.charAt(2) == '(') {
      count = 1;
      do {
        i++;
        switch(formula.charAt(i)) {
        case '(' : 
          count++;
          break;
        case ')' : 
          count--;
        }
        if(i > l) return false;
      } 
      while(count > 0);
      if(!validInputFormula(formula.substring(2, i + 1))) return false;
    }
    if(i + 1 != l) return false;
  }
  else {
    if(formula.substring(1, 4).equals(forall)) {
      if(formula.charAt(4) != ' ') return false;
      switch(formula.charAt(5)) {
      case '=' :
      case '&' :
      case '|' :
      case '~' :
      case ',' :
      case ')' : 
        return false;
      }
      i = 6;
      if(formula.charAt(6) == '(') {
        count = 1;
        do {
          i++;
          switch(formula.charAt(i)) {
          case '(' : 
            count++;
            break;
          case ')' : 
            count--;
          }
          if(i > l) return false;
        } 
        while(count > 0);
        if(!validInputFormula(formula.substring(6, i + 1))) return false;
      }
      if(i + 1 != l) return false;
    }
    else if(formula.substring(1, 3).equals(exists)) {
      if(formula.charAt(3) != ' ') return false;
      switch(formula.charAt(4)) {
      case '=' :
      case '&' :
      case '|' :
      case '~' :
      case ')' : 
        return false;
      }
      i = 5;
      if(formula.charAt(5) == '(') {
        count = 1;
        do {
          i++;
          switch(formula.charAt(i)) {
          case '(' : 
            count++;
            break;
          case ')' : 
            count--;
          }
          if(i > l) return false;
        } 
        while(count > 0);
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
        case ')' : 
          return false;
        }
        i = 2;
        if(formula.charAt(2) == '(') {
          count = 1;
          do {
            i++;
            switch(formula.charAt(i)) {
            case '(' : 
              count++;
              break;
            case ')' : 
              count--;
            }
            if(i > l) return false;
          } 
          while(count > 0);
          if(!validInputFormula(formula.substring(2, i + 1))) return false;
        }
        switch(formula.charAt(i + 1)) {
        case '=' :
        case '&' :
        case '|' :
        case ')' : 
          return false;
        }
        j = i += 1;
        if(formula.charAt(j) == '(') {
          count = 1;
          do {
            j++;
            switch(formula.charAt(j)) {
            case '(' : 
              count++;
              break;
            case ')' : 
              count--;
            }
            if(j > l) return false;
          } 
          while(count > 0);
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
        case ')' : 
          return false;
        }
        if(l > 5) return false;
      }
    }
  }
  println("Formula " + formula + " is ok!");
  return true;
}

String removeWhiteSpaceInfix(String input) {
  int l = input.length();
  int i = 0;
  boolean remove = false;
  while(i < l - 1) {
    if(input.charAt(i) == ' ') {
      if(i < l - 1) {
        if(i > 3) {
          if((input.charAt(i - 2) != '(' || (input.charAt(i + 1) == implies || input.charAt(i + 1) == and || input.charAt(i + 1) == or)) && !input.substring(i - 3, i).equals(forall) && !input.substring(i - 2, i).equals(exists)) remove = true;
        }
        else if(i == 2) {
          if((input.charAt(i - 2) != '(' || (input.charAt(i + 1) == implies || input.charAt(i + 1) == and || input.charAt(i + 1) == or))) remove = true;
          else if(i == 3) {
            if((input.charAt(i - 2) != '(' || (input.charAt(i + 1) == implies || input.charAt(i + 1) == and || input.charAt(i + 1) == or)) && !input.substring(i - 2, i).equals(exists)) remove = true;
          }
        }
        else remove = true;
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

String removeWhiteSpace(String input) {
  int l = input.length();
  int i = 0;
  boolean remove = false;
  while(i < l) {
    if(input.charAt(i) == ' ') {
      if(i >= 4) {
        if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == implies || input.charAt(i - 1) == and || input.charAt(i - 1) == or || input.charAt(i - 1) == '~')) && !input.substring(i - 3, i).equals(forall) && !input.substring(i - 2, i).equals(exists)) remove = true;
      }
      else if(i < 2) {
        remove = true;
      }
      else if(i == 2) {
        if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == implies || input.charAt(i - 1) == and || input.charAt(i - 1) == or || input.charAt(i - 1) == '~'))) remove = true;
      }
      else if(i == 3) {
        if((input.charAt(i - 2) != '(' || (input.charAt(i - 1) == implies || input.charAt(i - 1) == and || input.charAt(i - 1) == or || input.charAt(i - 1) == '~')) && !input.substring(i - 2, i).equals(exists)) remove = true;
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
  String infix;
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
    if(x > 0 && x < sizeX - 30) this.x = x;
    else if(x < 0) this.x = 0;
      else this.x = sizeX - 30;
    if(y < sizeY - 30) this.y = y;
    else this.y = sizeY - 30;
    this.c = color(128, 128, 0);
    this.s = t;
    if(t.length() > 3) this.infix = prefix2infix(t.substring(1, t.length() - 1));
    else this.infix = t.substring(1, 2);
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
    this.c = cm;
  }

  void finished() {
    if(!this.isFirst()) this.c = defaultColor;
  }

  void undo() {
    this.c = color(128, 128, 0);
    this.expanded = false;
  }

  void update(int X, int Y) {
    this.x = X - round(l1/2);
    this.y = Y - round(l2/2);
  }

  void display() {
    String t, a;
    fill(c);
    stroke(c1);
    textFont(myfont);
    a = removeFromLabel(s);
    if(prefix) t = a.substring(0, 1) + ": " + a.substring(1, a.length()) + " " + fromLabel(s);
    else t = s.substring(0, 1) + ": " + infix + " " + fromLabel(s);
    text(label + " - " + t, x, y);
    line(x1, y1, x2, y2);
  }

  boolean isFirst() {
    return this.first;
  }

  private String removeFromLabel(String formula) {
    if(formula.length() > 1) {
      int i = formula.length() - 2;
      while(formula.charAt(i) == '0' || formula.charAt(i) == '1' || formula.charAt(i) == '2' || formula.charAt(i) == '3' || formula.charAt(i) == '4' || formula.charAt(i) == '5' || formula.charAt(i) == '6' || formula.charAt(i) == '7' || formula.charAt(i) == '8' || formula.charAt(i) == '9') i--;
      return formula.substring(0, i + 1);
    }
    return "";
  }

  private String fromLabel(String formula) {
    if(formula.length() > 2) {
      int i = formula.length() - 1;
      while(formula.charAt(i) == '0' || formula.charAt(i) == '1' || formula.charAt(i) == '2' || formula.charAt(i) == '3' || formula.charAt(i) == '4' || formula.charAt(i) == '5' || formula.charAt(i) == '6' || formula.charAt(i) == '7' || formula.charAt(i) == '8' || formula.charAt(i) == '9') i--;
      return formula.substring(i + 1, formula.length());
    }
    return "";
  }

  String latex() {
    String formula = new String();
    String change = new String();
    String a = removeFromLabel(s);
    int i = 3;
    int clen = 1;
    int alen = 1;
    if(prefix) formula = a.substring(0, 1) + ": " + a.substring(1, s.length()) + " " + fromLabel(s);
    else formula = s.substring(0, 1) + ": " + infix + " " + fromLabel(s);
    while(i < formula.length() - 4) {
      switch(formula.charAt(i)) {
        case '&': change = "$\\wedge$";
                  clen = 1;
                  alen = 7;
                  break;
        case '|': change = "$\\vee$";
                  clen = 1;
                  alen = 5;
                  break;
        case '=': change = "$\\to$";
                  clen = 1;
                  alen = 4;
                  break;
        case '~': change = "$\\neg$";
                  clen = 5;
                  break;
        case 'E': if(formula.charAt(i + 1) == 'X') {
                    change = "$\\exists$";
                    clen = 2;
                    alen = 8;
                  }
                  break;
        case 'A': if(formula.charAt(i + 1) == 'L') {
                    change = "$\\forall$";
                    clen = 3;
                    alen = 8;
                  }
                  break;
        default: change = "";
                 clen = 0;
                 alen = 1;
      }
      if(clen > 0) formula = formula.substring(0, i) + change + formula.substring(i + clen, formula.length());
      i += alen;
    }
    return formula;
  }
}

String fromLabel(String formula) {
  int i = formula.length() - 2;
  while(formula.charAt(i) == '0' || formula.charAt(i) == '1' || formula.charAt(i) == '2' || formula.charAt(i) == '3' || formula.charAt(i) == '4' || formula.charAt(i) == '5' || formula.charAt(i) == '6' || formula.charAt(i) == '7' || formula.charAt(i) == '8' || formula.charAt(i) == '9') i--;
  return formula.substring(i + 1, formula.length());
}

String qtree(int index) {
  String qtreeL = new String();
  String qtreeR = new String();
  if(index == 0) {
    MobileRectangle formulaF = ((MobileRectangle) nos.get(index));
    qtreeL = "[." + formulaF.latex();
    qtreeR = " ]";
    index++;
  }
  for(int i = index; i < nos.size() - 1; i++) {
    MobileRectangle formula1 = ((MobileRectangle) nos.get(i));
    MobileRectangle formula2 = ((MobileRectangle) nos.get(i + 1));
    MobileRectangle formula3 = ((MobileRectangle) nos.get(i - 1));
    int f1 = int(fromLabel(formula1.s));
    int f2 = int(fromLabel(formula2.s));
    int f3 = int(fromLabel(formula3.s));
    if(f1 + 1 == f2) {}
    if(f1 == f2) {}
    else {
    }
  }
  return qtreeL + qtreeR;
}

void mousePressed() {
  MobileRectangle folha;
  exibedados();
  int indice = -1; 
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
    println("AQUIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII:    " + Integer.parseInt("123"));
    nopressed = (MobileRectangle) nos.get(indice);
    if(nopressed.canExpand()) {
      println("Ok, first time on this node... expanding!");
      undoAdd(nopressed);
      println("nopressed "+ nopressed.s + " " + nopressed.y + " "+ nopressed.label); 
      if(mouseButton == RIGHT) {
        int totalramos = countramos;
        for(int i = 0; i < totalramos; i++) {
          println("Entering if statement: " + " logbin = maxnos = "+ maxnos + " countramos= " + totalramos);
          int maximonosramo = maxnos;
          for(int j = 0; j <= maximonosramo; j++) {
            println("ramos[][] = " + ramos[i][j] + " i=" + i + " j=" + j);
            if(ramos[i][j] == nopressed.label) {
              if(branches(nopressed.s)) {
                nopressed.marcado();
                nopressed.expandNode();
                folha = border[i];
                println("Border node = " + folha.label + " i= " + i);
                MobileRectangle um = new MobileRectangle(folha.x - 6 * (folha.s).length(), folha.y + 40, res1(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x-3 * (folha.s).length(), folha.y + 35, false);
                nos.add(um);
                MobileRectangle dois = new MobileRectangle(folha.x + 6 * (folha.s).length(), folha.y + 40, res2(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x + 3 * (folha.s).length(), folha.y + 35, false);
                nos.add(dois);
                ramos[i][maxnos+1] = um.label;
                border[i] = um;
                for (int k = 0 ; k<= maxnos; k++) {
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
                  nopressed.expandNode();
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
                  else {
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
                        nopressed.expandNode();
                        folha = border[i];
                        println(" No da border = "+folha.label + " i= "+i);
                        MobileRectangle um = new MobileRectangle(folha.x, folha.y+40, uno(nopressed.s) + nopressed.label, folha.x, folha.y, folha.x, folha.y + 40, false);
                        nos.add(um);
                        ramos[i][maxnos+1] = um.label;
                        border[i] = um; 
                        maxnos++;
                      } 
                      else nopressed.finished();
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

boolean existential(String s) {
  print("testando exist");
  String[] m = match(s, "(.)\\((EX|ALL)\\s+([^\\s])\\s*(\\(.+\\)|.)\\)");
  if(m != null) {
    println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
    if(((m[1].equals("F")) && (m[2].equals("ALL"))) || ((m[1].equals("V")) &&(m[2].equals("EX")))) return (true);
    else return false;
  }
  else return false;
}   

boolean negation(String s) {
  print("testando negation");
  String[] m = match(s, "(.)\\((~).+\\)");
  if(m!=null) {
    println(m[0] + "1" + m[1]);
    return true;
  }
  else return false;
}

boolean universal(String s) {
  print("testando universal");
  String[] m = match(s, "(.)\\((EX|ALL)\\s+([^\\s])\\s*(\\(.+\\)|.)\\)");
  if(m!=null) {
    println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
    if (((m[1].equals("V")) && (m[2].equals("ALL"))) || ((m[1].equals("F")) &&(m[2].equals("EX")))) return (true);
    else return false;
  }
  else return false;
}        

boolean branches(String s) { 
  String[] m = match(s, "(.)\\((.)(\\(.+\\)|.)(\\(.+\\)|.)\\)");
  if(m!=null) {
    if(((m[1].equals("F")) && (m[2].equals("&"))) || ((m[1].equals("V")) &&(m[2].equals("|"))) || ((m[1].equals("V")) &&(m[2].equals("=")))) {
      return true;
    }
    else return false;
  }
  else return false;
}   

boolean notbranches(String s) {
  String [] m = match(s, "(.)\\((&|\\||=).+");
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
  String[] m = match(s, "(.)\\((.)(.+)\\)");
  println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3]);
  if(m[2].equals("~")) return (inv(m[1]) + m[3]);
  else return null;
}

String exist(String s) {
  String[] m = match(s, "(.)\\((EX|ALL)\\s+([^\\s])\\s*(\\(.+\\)|.)\\)");
  println(m[0] + "1" + m[1] + "2" + m[2] + "3" + m[3] + "4" + m[4]);
  constParam++;
  constantesCriadas.add("c" + constParam);
  return(m[1] + m[4].replace(m[3], "c" + constParam));
}

String forall(String s, MobileRectangle originalFormula) {
  String[] m = match(s, "(.)\\((EX|ALL)\\s+([^\\s])\\s*(\\(.+\\)|.)\\)");
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
  if(s.charAt(3) != '(') arg1 = s.substring(3, 4);
  else {
    p = 1;
    arg1 = arg1 + "(";
  }
  println("=> " + s + " " + arg1 + " " + p);
  while(p != 0) {
    if(s.charAt(i) == '(') p++;
    else if (s.charAt(i)==')') p = p - 1;
    arg1 = arg1+s.charAt(i);
    i++;
  } 
  String [] m = match(s, "(.)\\((.)(\\(.+\\)|.)(\\(.+\\)|.)\\)");
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
  String [] k = match(s, "(.+)\\)[0-9]+");
  s = k[1];
  println("s -->"+s);
  int i = s.length() - 1;
  String arg2 = "";
  int p = 0;
  if(s.charAt(i) != ')') {
    arg2=s.substring(i, i + 1);
  }
  else {
    p = 1;
    arg2 = ")" + arg2;
    i = i - 1;
  }
  println("=> " + s.substring(1, i + 1) + " " + arg2 + " " + p + " i=" + i);
  while(p != 0) {
    if (s.charAt(i)==')') p++;
    else if(s.charAt(i) == '(') p = p - 1;
    arg2 = s.charAt(i) + arg2;
    i = i - 1;
    println(s.substring(1, i + 1) + " p=" + p + " char=" + s.charAt(i));
  };
  String[] m = match(s, "(.)\\((.).+");
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

