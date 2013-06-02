package decency.assemInstr;

public class BGT extends AssemInstr {
	public Reg src1, src2;
	public String label;
	
	public BGT(Reg x, Reg y, String z){
		src1 = x;
		src2 = y;
		label = z;
	}

	@Override
	public String toString() {
		return "bgt " + src1 + ", " + src2 + ", " + label;
	}
}
