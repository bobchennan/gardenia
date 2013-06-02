package decency.assemInstr;

public class LWX extends AssemInstr {
	public Reg dst, src1, src2, src3;
	
	public LWX(Reg dst, Reg src1, Reg src2, Reg src3){
		this.dst = dst;
		this.src1 = src1;
		this.src2 = src2;
		this.src3 = src3;
	}

	@Override
	public String toString() {
		return "lwx " + dst + ", " + src1 + ", " + src2 + ", " + src3;
	}
}
