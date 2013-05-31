package decency.assembler;

import decency.assemInstr.*;
import java.util.*;

public class Assembler {
	List<String> binCode = new ArrayList<String>();
	List<AssemInstr> assemCode;
	int counter;
	Map<String, Integer> labelTable = new HashMap<String, Integer>();

	public Assembler(List<AssemInstr> l) {
		assemCode = l;
	}

	public List<String> binCodeGen() {
		counter = 0;
		for (AssemInstr ai : assemCode) {
			if (ai instanceof LABEL) {
				labelTable.put(((LABEL) ai).label, counter);
				continue;
			} else if (ai instanceof ADD)
				gen((ADD) ai);
			else if (ai instanceof MUL)
				gen((MUL) ai);
			else if (ai instanceof BGT)
				gen((BGT) ai);
			else if (ai instanceof BNEZ)
				gen((BNEZ) ai);
			else if (ai instanceof LW)
				gen((LW) ai);
			else if (ai instanceof SW)
				gen((SW) ai);
			else if (ai instanceof J)
				gen((J) ai);
			else if (ai instanceof MV)
				gen((MV) ai);
			else if (ai instanceof LWX)
				gen((LWX) ai);
			else if (ai instanceof SWX)
				gen((SWX) ai);
			else {
				emit("");// NOP
				System.err.println("Undefined assemble instruction.");
			}
			++counter;
		}
		return binCode;
	}

	void emit(String s) {
		binCode.add(Util.widen(s, 32));
	}

	void gen(ADD ai) {
		if (ai.src2 instanceof Reg)
			emit("1000" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1000" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(MUL ai) {
		if (ai.src2 instanceof Reg)
			emit("1001" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1001" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(BGT ai) {
		emit("1010" + ai.src1.gen() + ai.src2.gen()
				+ Util.widen(labelTable.get(ai.label) - counter, 16));
	}

	void gen(BNEZ ai) {
		emit("1011" + ai.src.gen()
				+ Util.widen(labelTable.get(ai.label) - counter, 20));
	}

	void gen(LW ai) {
		if (ai.src2 instanceof Reg)
			emit("1100" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1100" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(SW ai) {
		if (ai.src2 instanceof Reg)
			emit("1101" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1101" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(J ai) {
		emit("1110" + Util.widen(labelTable.get(ai.label) - counter, 28));
	}

	void gen(MV ai) {
		if (ai.src instanceof Reg)
			emit("1111" + ai.dst.gen() + ((Reg) (ai.src)).gen());
		else
			emit("1111" + ai.dst.gen() + Util.widen(((Imm) (ai.src)).imm, 19)
					+ "1");
	}

	void gen(LWX ai) {
		emit("0001" + ai.dst.gen() + ai.src1.gen() + ai.src2.gen()
				+ ai.src3.gen());
	}

	void gen(SWX ai) {
		emit("0010" + ai.dst.gen() + ai.src1.gen() + ai.src2.gen()
				+ ai.src3.gen());
	}
}
