module matmul_m
    implicit none
    private
    public :: matmul_t

    ! sum(T) --> T
    RESTRICTION reduction_operation(T, op)
       type :: T; end type
       interface
          pure function op(arr)
             type(T) :: arr(:)
             type(T) :: op
          end function op
       end interface
    END RESTRICTION

    ! T * U -> V
    RESTRICTION binary_operation(op, T, U, V)
       type :: T; end types
       type :: U; end type
       type :: V; end type
       interface
           elemental function op(x, y) result(z)
              type(T), intent(in) :: x
              type(U), intent(in) :: y
              type(V) :: z
           end function
       end interface
    END RESTRICTION

    !---------------------------
    TEMPLATE matmul_t(T, U, V, times, sum)
        private
        public :: matmul
        REQUIRES binary_operation(times, T, U, V)
        REQUIRES reduction_operation(sum, V)

        interface matmul
            module procedure matmul_
        end interface

    contains

        function matmul_(A, B) result(C)
            type(T), intent(in) :: A(:,:)
            type(U), intent(in) :: B(:,:)
            type(V), allocatable :: C(:, :)

            integer :: i, j
            integer :: ni, nj, nk

            ni = size(A,dim=1)
            nj = size(B,dim=2)
            nk = size(A,dim=2)

            if (size(B, dim=1) /= nk) error stop "Mismatched matrix sizes"

            allocate(C(ni,nj))
            do concurrent (i = 1:ni, j = 1:nj)
                C(i,j) = sum(times(A(i,:),B(:,j)))
            end do
        end function

    END TEMPLATE
    !---------------------------
end module
