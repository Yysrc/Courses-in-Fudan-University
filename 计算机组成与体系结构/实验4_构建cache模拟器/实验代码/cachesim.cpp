/*
�������
g++ cachesim.cpp -o cachesim
./cachesim -c cfg.txt -t ls.trace -o ls.trace.out
*/

#include<iostream>
#include<fstream>
#include<string>
#include<cmath>
#include<iomanip>
using namespace std;

typedef struct Cache{
	unsigned long long tag;	//���
	int cnt;				//������
	int V;					//��Чλ
	Cache() {				//���캯��
		tag = 0;
		cnt = 0;
		V = 0;
	}
} CacheLine;

CacheLine** Initialization(unsigned int groupSum, unsigned int associativity){
	//groupSum������Ŀ
	//associativity�������ȣ�ֱ��ӳ��Ϊ1��ȫ����ӳ��Ϊcache����
	CacheLine** cache;
	cache = new CacheLine*[groupSum];
	for (int i = 0; i != groupSum; ++i) {
		cache[i] = new CacheLine[associativity]{};
	}
	return cache;
}

void Clean(CacheLine** cache, unsigned int groupSum){
	for(int i = 0; i != groupSum; ++i)
		delete[] cache[i];
	delete[] cache;
}

void CacheWorkLRU(CacheLine** cache, unsigned long long memTag,
	unsigned long long groupNum, int associativity, char readorWrite,
	int missCost, int writeMethod, int& hits, int& loadHits, int& storeHits, int& cycles) {
	//LRU�滻

	CacheLine* line = cache[groupNum];

	//����һ�����������зǿ���֮��
	for (int i = 0; line[i].V == 1; ++i) {
		//����
		if (memTag == line[i].tag) {
			//��������ֵ
			hits++;
			cycles++;
			if (readorWrite == 'R') loadHits++;
			else if (readorWrite == 'W') storeHits++;
			//�������仯
			for (int j = 0; line[j].V == 1; ++j) {
				if (line[j].cnt < line[i].cnt) {
					line[j].cnt++;
				}
			}
			line[i].cnt = 0;
			//�������򷵻�
			return;
		}
	}

	//δ����
	cycles += missCost;			//�÷����п�������������
	int evictionIndex = 0;		//��������
	int i = 0;
	int max = 0;
	for (i = 0; line[i].V == 1; ++i) {
		//����λ��1,��¼���ܵģ����޿��У��滻�е�����
		if (line[i].cnt > max) {
			max = line[i].cnt;
			evictionIndex = i;
		}
		line[i].cnt++;
	}

	if (i != associativity){
		//�п���
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//����������д������ȫд��������cache
			line[i].V = 1;
			line[i].tag = memTag;
			line[i].cnt = 0;
		}
		return;
	}
	else {
		// �޿���
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//����������д������ȫд��������cache
			line[evictionIndex].tag = memTag;
			line[evictionIndex].cnt = 0;
			line[evictionIndex].V = 1;
			return;
		}
	}
}


void CacheWorkRand(CacheLine** cache, unsigned long long memTag,
	unsigned long long groupNum, int associativity, char readorWrite,
	int missCost, int writeMethod, int& hits, int& loadHits, int& storeHits, int& cycles) {
	//����滻
	CacheLine* line = cache[groupNum];

	for (int i = 0; line[i].V == 1; ++i) {
		//����
		if (memTag == line[i].tag) {
			hits++;
			cycles++;
			if (readorWrite == 'R') loadHits++;
			else if (readorWrite == 'W') storeHits++;
			return;
		}
	}

	//δ����
	cycles += missCost;
	int evictionIndex = 0;
	int i = 0;
	for (i = 0; line[i].V == 1; ++i);

	if (i != associativity) {
		//�п���
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//����������д������ȫд��������cache
			line[i].tag = memTag;
			line[i].V = 1;
		}
		return;
	}
	else {
		// �޿���
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//����������д������ȫд��������cache
			evictionIndex = (rand() % associativity);
			line[evictionIndex].tag = memTag;
			line[evictionIndex].V = 1;
			return;
		}
	}
}

int main(int argc, char* argv[])
{
	ifstream fin;
	fin.open(argv[2]);
	if (!fin) {
		cout << "Cannot open file " << argv[2] << "!" << endl;
		exit(1);
	}
	int blockSize;						//���С��B��
	unsigned int associativityMark;		//���ݴ�С��KB��
	unsigned long dataSize;				//�����Ա�ǣ��������ļ�����
	int replaceMethod;					//�滻����
	int missCost;						//�����п���
	int writeMethod;					//д�뷽��

	fin >> blockSize >> associativityMark >> dataSize
		>> replaceMethod >> missCost >> writeMethod;
	fin.close();

	int q, k;	//q��cache���λ���� k�����ڵ�ַλ��

	unsigned int groupSum, associativity;

	k = (int)log2(blockSize);
	if (associativityMark != 0) {
		//ֱ��ӳ�䣨�൱��ÿ��1�У�&������ӳ��
		associativity = associativityMark;
		groupSum = dataSize * 1024 / blockSize / associativity;
		q = (int)log2(groupSum);
	}
	else {
		//ȫ����ӳ��
		groupSum = 1;
		//�����ȼ�Ϊcache����
		associativity = dataSize * 1024 / blockSize;
		q = 0;	//�����,q��Ϊ0
	}

	CacheLine** cache = Initialization(groupSum, associativity);

	int hits = 0;
	int sum = 0;
	int loadHits = 0;
	int loadSum = 0;
	int storeHits = 0;
	int storeSum = 0;
	int cycles = 0;

	fin.open(argv[4]);
	if (!fin) {
		cout << "Cannot open file " << argv[4] << "!" << endl;
		exit(1);
	}

	while (fin) {
		string instructionAddr;
		char readorWrite;
		string dataAddr;
		fin >> instructionAddr >> readorWrite >> dataAddr;
		sum++;
		if (readorWrite == 'R') loadSum++;
		else storeSum++;

		if (instructionAddr == "#eof") break;
		unsigned long long addr = stoll(dataAddr, nullptr, 16);
		unsigned long long memTag = addr >> (q + k);
		//ͨ������q��k��λ����õ�memTag��groupNum
		unsigned long long groupNum = ((addr << (64 - q - k)) >> (64 - q));
		//��Ȼ�����ļ��е�ַ��48λ����ʵ�ʱ���ʱ��64λ

		if (replaceMethod) {
			CacheWorkLRU(cache, memTag, groupNum, associativity, readorWrite,
				missCost, writeMethod, hits, loadHits, storeHits, cycles);
		}
		else {
			CacheWorkRand(cache, memTag, groupNum, associativity, readorWrite,
				missCost, writeMethod, hits, loadHits, storeHits, cycles);
		}
	}
	fin.close();
	
	ofstream ofs;
	ofs.open(argv[6], ios::out);

	ofs.setf(ios::fixed);
	ofs.precision(4);
	ofs << "Total Hit Rate: " << ((float)hits / sum * 100) << "%" << endl;
	ofs.precision(2);
	ofs << "Load Hit Rate: " << ((float)loadHits / loadSum * 100) << "%" << endl;
	ofs << "Store Hit Rate: " << ((float)storeHits / storeSum * 100) << "%" << endl;
	ofs << "Total Run Time: " << cycles << endl;
	ofs << "AVG MA Latency: " << ((float)cycles / sum) << endl;

	ofs.close();

	Clean(cache, groupSum);
	return 0;
}
