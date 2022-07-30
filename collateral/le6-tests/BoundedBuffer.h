#ifndef _BOUNDEDBUFFER_H_
#define _BOUNDEDBUFFER_H_

#include <assert.h>

#include <condition_variable>
#include <mutex>
#include <queue>
#include <string.h>
#include <vector>


class BoundedBuffer {
private:
    // max number of items in the buffer
	int cap;

    /* The queue of items in the buffer
     * Note that each item a sequence of characters that is best represented by a vector<char> for 2 reasons:
	 *  1. An STL std::string cannot keep binary/non-printables
	 *  2. The other alternative is keeping a char* for the sequence and an integer length (b/c the items can be of variable length)
	 * While this would work, it is clearly more tedious
     */
	std::queue<std::vector<char>> q;

	// add necessary synchronization variables and data structures
	std::mutex mtx;
	std::condition_variable pop_ready;	// waited by pop, signaled by push
	std::condition_variable push_ready;	// waited by push, signaled by pop

public:
	BoundedBuffer (int _cap);
	~BoundedBuffer ();

	void push (char* msg, int size);
	int pop (char* msg, int size);

	size_t size ();
};

#endif
