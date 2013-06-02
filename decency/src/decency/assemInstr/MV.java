package decency.assemInstr;

public class MV extends AssemInstr {
	public Reg dst;
	public Operand src;
	
	public MV(Reg x, Operand y){
		dst = x;
		src = y;
	}

	@Override
	public String toString() {
		return "mv " + dst + ", " + src;
	}
}
