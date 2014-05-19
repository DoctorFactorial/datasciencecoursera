## Below functions cache the inverse of a given matrix


## makeCacheMatrix is used to initialise matrix to be inverted
makeCacheMatrix <- function(x = matrix()) {
        m <- NULL
        set <- function(y) {
                x <<- y
                m <<- NULL
        }
        get <- function() x
        setinverse <- function(solve) m <<- solve
        getinverse <- function() m
        list(set = set, get = get,
             setinverse = setinverse,
             getinverse = getinverse)
}


## cacheSolve computes matrix inverse when called for the first time 
## returning cached data each time subsequently

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
        m <- x$getinverse()
        if(!is.null(m)) {
                message("getting cached data")
                return(m)
        }
        data <- x$get()
        m <- solve(data, ...)
        x$setinverse(m)
        m
}


## Example:

# a <- makeCacheMatrix()                        #initialize
# a$set(matrix(1:4, nrow = 2, ncol = 2))        #set the vector
# a$get                                         #get the vector 
# cacheSolve(a)                                 #calculate the inverse 
# cacheSolve(a)                                 #when is called back use the cached mean 