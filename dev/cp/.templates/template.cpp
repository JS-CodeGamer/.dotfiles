// Problem: $(PROBLEM)
// Contest: $(CONTEST)
// Judge: $(JUDGE)
// URL: $(URL)
// Memory Limit: $(MEMLIM)
// Time Limit: $(TIMELIM)
// Start: $(DATE)

#include <bits/stdc++.h>
using namespace std;

/*-- TEMPLATE --*/
#define il inline
typedef long int l;
typedef long long int ll;
#define VARGS_(_10, _9, _8, _7, _6, _5, _4, _3, _2, _1, N, ...) N
#define VARGS(...) VARGS_(__VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
#define CONCAT_(a, b) a##b
#define CONCAT(a, b) CONCAT_(a, b)
// clang-format off
#define rep_4(start, var, end, step) for (int var = start; var < end; var += step)
// clang-format on
#define rep_3(start, var, end) rep_4(start, var, end, 1)
#define rep_2(var, end) rep_3(0, var, end)
#define rep_1(end) rep_3(0, i, end)
#define rep(...) CONCAT(rep_, VARGS(__VA_ARGS__))(__VA_ARGS__)
#define pii pair<int, int>
#define dbg(...) logger(#__VA_ARGS__, __VA_ARGS__)
const int MOD = 1e9 + 7;
template <typename T> T mod(T a, T b) { return (a + b) % MOD; }
/* TEMPLATE END */

template <typename... Args> void logger(string vars, Args &&...values) {
  cout << vars << " = ";
  string delim = " ";
  (..., (cout << delim << values, delim = ", "));
  cout << '\n';
}

bool iter = false;
void solve(int tcase) {}

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(NULL);
  int tcases = 1;
  string judge = "$(JUDGE)";
  if (judge == "Codeforces" || iter == true) {
    cin >> tcases;
  }
  for (int tcase = 0; tcase < tcases; tcase++) {
    solve(tcase);
  }
  return 0;
}
