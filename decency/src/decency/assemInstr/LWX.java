package decency.assemInstr;

public class LWX extends AssemInstr {
	public Reg dst, src1, src2, src3;

	@Override
	public String toString() {
		return "lwx " + dst + ", " + src1 + ", " + src2 + ", " + src3;
	}
}
