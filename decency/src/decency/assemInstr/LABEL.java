package decency.assemInstr;

public class LABEL extends AssemInstr {
	public String label;
	public static int cnt = 0;
	public LABEL(String x){
		label = x;
	}
	
	public static LABEL neww(){
		++cnt;
		return new LABEL("L"+cnt);
	}
	
	@Override
	public String toString() {
		return label + ": ";
	}
}
