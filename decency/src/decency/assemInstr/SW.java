package decency.assemInstr;

public class SW extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;
	
	public SW(Reg dst, Reg src1, Operand src2){
		this.dst = dst;
		this.src1 = src1;
		this.src2 = src2;
	}

	@Override
	public String toString() {
		return "sw " + dst + ", " + src1 + ", " + src2;
	}
}
