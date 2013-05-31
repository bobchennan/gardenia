package decency.assemInstr;

public class SWX extends AssemInstr {
	public Reg dst, src1, src2, src3;

	@Override
	public String toString() {
		return "swx " + dst + ", " + src1 + ", " + src2 + ", " + src3;
	}
}
